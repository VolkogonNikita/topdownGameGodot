extends CharacterBody2D

var player = null
var player_is_in_area = false
var label_e = preload("res://label_e.tscn")
var label_name = preload("res://label_name.tscn")
var label_p = preload("res://label_e.tscn")
var label_p_instance = null
var label_e_instance = null
var label_name_instance = null
@onready var input_field: LineEdit = $LineEdit
@onready var answer_label: Label = $Label

var python_script_path = "D:/учёба/3 курс/6 сем/ЕЯИИС/еяиис2/voice_recognition.py"
var output_file_path = "res://output.txt"
var is_processing = false

func _ready() -> void:
	input_field.visible = false

func _process(delta: float) -> void:
	show_label_name()
	if player_is_in_area and label_e_instance == null:
		show_label_p()
	if player_is_in_area and Input.is_action_just_pressed("e") and not is_processing:
		start_voice_recognition()
	if player_is_in_area and Input.is_action_just_pressed("p"):
		open_input_field()
		
func open_input_field():
	input_field.visible = true
	input_field.text = ""        
	input_field.grab_focus()     

func _on_line_edit_text_submitted(text: String):
	input_field.visible = false
	if text.strip_edges() == "":
		return
	dialog_with_llama(text)

func dialog_with_llama(text):
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_test_completed)
	
	var url = "http://127.0.0.1:8000/generate"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({"text": text, "max_new_tokens": 30})
	
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	print("Отправлен тестовый запрос, ошибка:", error)

func _on_test_completed(result, response_code, headers, body):
	print("Тестовый ответ получен! Код:", response_code)
	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		print("LLaMA ответил:", data["response"])
		answer_label.text = data["response"]

func start_voice_recognition():
	is_processing = true
	update_label_text("Слушаю...")
	
	var thread = Thread.new()
	thread.start(_execute_in_thread)

func _execute_in_thread():
	execute_python_script(python_script_path)
	
	call_deferred("_on_script_completed")

func _on_script_completed():
	is_processing = false
	var result = read_output_file(output_file_path)
	update_label_text(result)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_is_in_area = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_is_in_area = false
		#hide_label_e()
		hide_label_p()

func show_label_name():
	label_name_instance = label_name.instantiate()
	var label_node = label_name_instance.get_node("Label")
	label_node.text = "NPC()"
	label_name_instance.global_position = $Marker2D_name.global_position
	get_parent().add_child(label_name_instance)

func show_label_e():
	label_e_instance = label_e.instantiate()
	label_e_instance.global_position = $Marker2D_label.global_position
	get_parent().add_child(label_e_instance)

func show_label_p():
	label_p_instance = label_p.instantiate()
	label_p_instance.global_position = $Marker2D_label.global_position
	get_parent().add_child(label_p_instance)

func hide_label_e():
	if label_e_instance != null:
		label_e_instance.queue_free()
		label_e_instance = null

func hide_label_p():
	if label_p_instance != null:
		label_p_instance.queue_free()
		label_p_instance = null

func execute_python_script(script_path: String) -> void:
	var python_path = "D:/python_interpreter/Scripts/python.exe"
	var exit_code = OS.execute(python_path, [script_path], [])
	
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
	
func update_label_text(new_text: String) -> void:
	if label_e_instance != null:
		var label_node = label_e_instance.get_node("Label")
		if label_node != null:
			label_node.text = new_text
