extends Node
class_name HTTP

@onready var http := HTTPRequest.new()

signal response_received(text: String)

const API_URL := "http://127.0.0.1:8000/chat"

func _ready() -> void:
	add_child(http)
	http.request_completed.connect(_on_request_completed)


func send_message(message: String, npc: String = "miroslav") -> void:

	print("Отправляю запрос к LLaMA...")

	var headers := [
		"Content-Type: application/json"
	]

	var body := {
		"npc": npc,
		"message": message
	}

	var json_body := JSON.stringify(body)

	var error := http.request(
		API_URL,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if error == OK:
		print("Запрос отправлен успешно")
	else:
		print("Ошибка отправки: ", error)


func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	print("\n=====")
	print("Ответ от сервера получен")
	print("HTTP код: ", response_code)

	var response_text := ""

	if response_code == 200:

		var json := JSON.new()

		var parse_result = json.parse(
			body.get_string_from_utf8()
		)

		if parse_result == OK:

			var data = json.get_data()

			response_text = data.get(
				"answer",
				"Пустой ответ"
			)

			print("Ответ NPC: ", response_text)

		else:

			response_text = "Ошибка парсинга JSON"

			print("Ошибка JSON")

	else:

		response_text = "Ошибка сервера"

		print(body.get_string_from_utf8())

	print("=====")

	response_received.emit(response_text)
