extends Node

var python_script_path = "D:/учёба/3 курс/6 сем/ЕЯИИС/еяиис2/voice_recognition.py"
var output_file_path = "res://output.txt"

func _ready():
	test_python_environment()

func _on_button_pressed() -> void:
	execute_python_script(python_script_path)
	var result = read_output_file(output_file_path)
	$Label.text = result

func execute_python_script(script_path: String) -> void:
	var python_path = "D:/python_interpreter/Scripts/python.exe"
	var args = []
	var exit_code = OS.execute(python_path, [script_path], args)
	
	if exit_code != 0:
		print("Ошибка выполнения скрипта")
		return

func read_output_file(file_path: String) -> String:
	if not FileAccess.file_exists(file_path):
		print("Файл с результатом не найден")
		return "Ошибка"
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Не удалось открыть файл")
		return "Ошибка"
	
	var result = file.get_as_text()
	file.close()
	
	print("Содержимое файла: ", result)
	return result
	
func test_python_environment():
	var python_path = "D:/python_interpreter/Scripts/python.exe"
	var args = ["-c", "import torch; print(torch.__version__)"]
	
	var output = []
	var exit_code = OS.execute(python_path, args, output, false)
	
	print("Python test output: ", output)
