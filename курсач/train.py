# train.py - исправленная версия
import os
import logging
import asyncio
import gc
import traceback
from concurrent.futures import ThreadPoolExecutor
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from llama_cpp import Llama

# -------------------------
# CONFIG
# -------------------------
MODEL_PATH = "gguf/.cache/Llama-3.2-1B-Instruct-Q8_0.gguf"
N_THREADS = 8
CTX_SIZE = 2048
N_BATCH = 512  # Добавили

MAX_CONCURRENT_GENERATIONS = 1  # ТОЛЬКО 1 ОДНОВРЕМЕННЫЙ ЗАПРОС!

# -------------------------
# LOGGING
# -------------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("llama-fastapi")

# -------------------------
# FastAPI
# -------------------------
app = FastAPI(title="LLaMA GGUF Dialogue Server")

# Добавляем CORS для Godot
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # В production замените на конкретные домены
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# -------------------------
# Pydantic
# -------------------------
class GenerateRequest(BaseModel):
    text: str
    style: Optional[str] = "нейтрально"
    persona: Optional[str] = "NPC из средневековой игры"
    max_new_tokens: Optional[int] = 80
    temperature: Optional[float] = 0.7
    top_p: Optional[float] = 0.9
    do_sample: Optional[bool] = True


class GenerateResponse(BaseModel):
    response: str
    error: Optional[str] = None
    prompt_used: Optional[str] = None


# -------------------------
# Globals
# -------------------------
llm = None
executor = ThreadPoolExecutor(max_workers=MAX_CONCURRENT_GENERATIONS)
generation_semaphore = asyncio.Semaphore(MAX_CONCURRENT_GENERATIONS)

# Мьютекс для защиты модели от конкурентного доступа
model_lock = asyncio.Lock()


# -------------------------
# Build system message
# -------------------------
def build_system_message(persona: str, style: str) -> str:
    style_sentence = {
        "нейтрально": "Отвечай нейтрально, кратко и вежливо.",
        "дружелюбно": "Отвечай дружелюбно, тепло и приветливо.",
        "шутливо": "Отвечай с лёгкой шуткой, но корректно и кратко."
    }.get(style, "Отвечай нейтрально, кратко и вежливо.")

    return f"""Ты — {persona}.
{style_sentence}
Правила:
1) Всегда отвечай на русском языке.
2) Держись роли персонажа.
3) Отвечай 1–2 предложениями.
4) Не повторяй фразу пользователя.
5) Не говори, что ты ИИ.
6) Ничего не говори про игру, ты персонаж из игры
7) Не повторяй слова друг за другом"""


# -------------------------
# Build full prompt
# -------------------------
def build_prompt(system_message: str, user_message: str) -> str:
    # Правильный формат для Llama 3.2 без дублирования
    return f"""<|start_header_id|>system<|end_header_id|>

{system_message}<|eot_id|><|start_header_id|>user<|end_header_id|>

{user_message}<|eot_id|><|start_header_id|>assistant<|end_header_id|>

"""


# -------------------------
# Sync generation function with error handling
# -------------------------
def generate_sync(prompt: str, max_new_tokens, temperature, top_p, do_sample):
    global llm

    try:
        logger.info(f"Generating with max_tokens={max_new_tokens}, temp={temperature}")

        # Основной вызов генерации
        out = llm(
            prompt,
            max_tokens=max_new_tokens,
            temperature=temperature,
            top_p=top_p,
            stop=["<|end_of_text|>", "<|eot_id|>", "</s>"],
            echo=False  # Не возвращаем промпт
        )

        text = out["choices"][0]["text"].strip()

        # Очистка от возможных артефактов
        text = text.replace("<|end_of_text|>", "").replace("<|eot_id|>", "").strip()

        logger.info(f"Generated {len(text)} characters")
        return text

    except Exception as e:
        logger.error(f"Generation error: {e}")
        logger.error(traceback.format_exc())
        raise


# -------------------------
# Startup — load GGUF with error recovery
# -------------------------
@app.on_event("startup")
def load_model():
    global llm

    logger.info(f"Loading GGUF model from {MODEL_PATH} ...")

    try:
        # Полная очистка перед загрузкой
        if llm is not None:
            del llm
            gc.collect()

        # Загружаем с правильными параметрами
        llm = Llama(
            model_path=MODEL_PATH,
            n_threads=N_THREADS,
            n_ctx=CTX_SIZE,
            n_batch=N_BATCH,
            verbose=False,
            use_mmap=True,  # Используем mmap
            use_mlock=False,  # Не фиксируем в RAM
            n_gpu_layers=0,  # 0 = CPU only, увеличьте если есть GPU
        )

        # Тестовая генерация для проверки
        test_prompt = "Hello"
        test_output = llm(test_prompt, max_tokens=1, temperature=0)
        logger.info(f"Model test passed. Sample output: {test_output}")

        logger.info("✅ GGUF model loaded successfully.")

    except Exception as e:
        logger.exception(f"❌ Failed to load GGUF model: {e}")
        llm = None
        raise


# -------------------------
# Shutdown — clean up
# -------------------------
@app.on_event("shutdown")
def shutdown_event():
    global llm
    logger.info("Shutting down LLaMA server...")

    if llm is not None:
        logger.info("Freeing model memory...")
        del llm
        llm = None
        gc.collect()

    logger.info("✅ Server shutdown complete")


# -------------------------
# /health
# -------------------------
@app.get("/health")
async def health():
    status = "healthy" if llm is not None else "unhealthy"
    return {
        "status": status,
        "model_loaded": llm is not None,
        "model_path": MODEL_PATH
    }


# -------------------------
# /generate with full protection
# -------------------------
@app.post("/generate", response_model=GenerateResponse)
async def generate_endpoint(req: GenerateRequest):
    if not req.text.strip():
        raise HTTPException(status_code=400, detail="text is empty")

    if llm is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    # Проверяем параметры
    if req.max_new_tokens > 512:
        raise HTTPException(status_code=400, detail="max_new_tokens too high")

    try:
        system_message = build_system_message(req.persona, req.style)
        prompt = build_prompt(system_message, req.text.strip())

        # ЗАЩИТА: используем мьютекс и семафор
        async with generation_semaphore:
            async with model_lock:
                loop = asyncio.get_running_loop()
                result = await loop.run_in_executor(
                    executor,
                    generate_sync,
                    prompt,
                    req.max_new_tokens,
                    req.temperature,
                    req.top_p,
                    req.do_sample,
                )

        return GenerateResponse(
            response=result,
            prompt_used=prompt[:200] + "..." if len(prompt) > 200 else prompt
        )

    except Exception as e:
        logger.error(f"Endpoint error: {e}")
        logger.error(traceback.format_exc())

        # Пытаемся восстановить модель при критических ошибках
        if "access violation" in str(e) or "0x0000000000000000" in str(e):
            logger.warning("Critical memory error detected, attempting model reload...")
            try:
                load_model()  # Перезагружаем модель
            except:
                pass

        raise HTTPException(
            status_code=500,
            detail=f"Generation failed: {str(e)}"
        )


# -------------------------
# Simple test endpoint
# -------------------------
@app.get("/test")
async def test():
    if llm is None:
        return {"error": "Model not loaded"}

    try:
        test_result = llm("Hello", max_tokens=5, temperature=0)
        return {
            "status": "working",
            "test_output": test_result["choices"][0]["text"],
            "model_info": str(llm)
        }
    except Exception as e:
        return {"error": str(e)}


# -------------------------
# RUN
# -------------------------
if __name__ == "__main__":
    import uvicorn

    # Запускаем с одним воркером
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8000,
        workers=1,  # ВАЖНО: только 1 воркер!
        log_level="info"
    )