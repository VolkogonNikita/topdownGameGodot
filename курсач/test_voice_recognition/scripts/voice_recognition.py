import speech_recognition as sr

class VoiceRecognition:
    def __init__(self):
        self.recognizer = sr.Recognizer()

    def recognize_speech(self):
        with sr.Microphone(device_index=1) as source:
            print("listen...")
            audio = self.recognizer.listen(source)

        try:
            query = self.recognizer.recognize_google(audio, language = 'ru_RU')
            return query.lower()
        except sr.UnknownValueError:
            return "Не удалось распознать аудио"
        except sr.RequestError as e:
            return f"Ошибка запроса к сервису Google Speech Recognition : {e}"

    def save_result_to_file(self, result, output_file="output.txt"):
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(result)
        print(f"Результат сохранён в файл: {output_file}")

if __name__ == "__main__":
    voice_recognition = VoiceRecognition
    result = voice_recognition.recognize_speech()
    output_file = "output.txt"
    voice_recognition.sace_result_to_file(result, output_file)