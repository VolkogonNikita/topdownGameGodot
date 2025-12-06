# SimpleLLaMATest.gd
extends Node

@onready var http = HTTPRequest.new()

func _ready():
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	
	# Ждем запуска сервера
	await get_tree().create_timer(2.0).timeout
	
	# Простой тест - только один запрос
	test_single_request()

func test_single_request():
	print("Отправляю тестовый запрос к LLaMA...")
	
	var url = "http://127.0.0.1:8000/generate"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"text": "Привет!",
		"max_new_tokens": 40,
		"temperature": 0.8
	})
	
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error == OK:
		print("Запрос отправлен успешно")
	else:
		print("Ошибка отправки:", error)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("\n" + "=======")
	print("Ответ от сервера получен!")
	print("HTTP код:", response_code)
	
	if response_code == 200:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			var data = json.get_data()
			print("✅ УСПЕХ!")
			print("Ответ LLaMA:", data["response"])
		else:
			print("❌ Ошибка парсинга JSON")
	else:
		print("❌ Ошибка сервера")
		print("Тело ответа:", body.get_string_from_utf8())
	
	print("==========")
	print("Нажмите ESC для выхода")
	
	# Не завершаем игру автоматически!

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
