import speech_recognition as sr
import subprocess

class VoiceRecognition:
    def __init__(self):
        self.recognizer = sr.Recognizer()

    def recognize_speech(self):
        with sr.Microphone() as source:
            print("Слушаю...")
            audio = self.recognizer.listen(source)

        try:
            query = self.recognizer.recognize_google(audio, language='ru_RU')
            return query.lower()
        except sr.UnknownValueError:
            return "Не удалось распознать аудио"
        except sr.RequestError as e:
            return f"Ошибка запроса: {e}"


    def save_result_to_file(self, result, output_file = "D:/учёба/диплом/test/test_voice_recognition/output.txt"):
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(result)
        print(f"Результат сохранён в файл: {output_file}")

if __name__ == "__main__":
    voice_recognition = VoiceRecognition()
    result = voice_recognition.recognize_speech()

    print(result)

    voice_recognition.save_result_to_file(result, "D:/учёба/диплом/test/test_voice_recognition/output.txt")

    subprocess.run([
        'D:/python_interpreter/Scripts/python.exe',
        'D:/учёба/3 курс/6 сем/ЕЯИИС/еяиис2/seq2seq.py'
    ])

