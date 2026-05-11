extends Node
class_name HTTP

signal response_received(npc_name: String, answer: String)
signal error_occurred(error_message: String)

@onready var http := HTTPRequest.new()
const API_URL := "http://127.0.0.1:8001/chat"

func _ready() -> void:
	add_child(http)
	http.request_completed.connect(_on_request_completed)

func send_message(message: String, npc_id: String = "miroslav") -> void:
	print("Отправляю запрос к серверу NPC...")
	print("NPC: ", npc_id)
	print("Сообщение: ", message)
	
	var headers := [
		"Content-Type: application/json"
	]
	
	var body := {
		"npc": npc_id,
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
		print("✅ Запрос отправлен успешно")
	else:
		print("❌ Ошибка отправки: ", error)
		error_occurred.emit("Ошибка отправки запроса: " + str(error))

func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	print("\n=====")
	print("Ответ от сервера получен")
	print("HTTP код: ", response_code)
	
	if response_code == 200:
		var json := JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var data = json.get_data()
			var npc_name = data.get("npc", "NPC")
			var answer = data.get("answer", "Нет ответа")
			
			print("NPC: ", npc_name)
			print("Ответ: ", answer)
			print("=====\n")
			
			response_received.emit(npc_name, answer)
		else:
			var error_msg = "Ошибка парсинга JSON"
			print("❌ ", error_msg)
			print(body.get_string_from_utf8())
			error_occurred.emit(error_msg)
	else:
		var error_body = body.get_string_from_utf8()
		print("❌ Ошибка сервера: ", error_body)
		error_occurred.emit("Сервер вернул ошибку " + str(response_code) + ": " + error_body)
