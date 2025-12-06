# SimpleTest.gd - самый простой тест
extends Node

func _ready():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_test_completed)
	
	var url = "http://127.0.0.1:8000/generate"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({"text": "Привет!", "max_new_tokens": 30})
	
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	print("Отправлен тестовый запрос, ошибка:", error)

func _on_test_completed(result, response_code, headers, body):
	print("Тестовый ответ получен! Код:", response_code)
	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		print("LLaMA ответил:", data["response"])
