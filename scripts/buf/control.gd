# SimpleLLaMATest.gd
extends Node
class_name HTTP

@onready var http = HTTPRequest.new()

signal response_received(text: String)

func _ready():
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	
	await get_tree().create_timer(2.0).timeout
	
	#test_single_request()

func test_single_request(text: String):
	print("Отправляю тестовый запрос к LLaMA...")
	
	var url = "http://127.0.0.1:8000/generate"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		#"text": "what's new in the kingdom",
		"text": text,
		"max_new_tokens": 100,
		"temperature": 0.8
	})
	
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error == OK:
		print("Запрос отправлен успешно")
	else:
		print("Ошибка отправки:", error)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("\n=====")
	print("Ответ от сервера получен!")
	print("HTTP код:", response_code)
	
	var response_text := ""

	if response_code == 200:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			var data = json.get_data()
			response_text = data.get("response", "Нет ответа")
			print("Ответ LLaMA:", response_text)
		else:
			response_text = "Ошибка JSON"
	else:
		response_text = "Ошибка сервера"

	print("=====")

	# 🔥 ВАЖНО: отправляем сигнал
	response_received.emit(response_text)
