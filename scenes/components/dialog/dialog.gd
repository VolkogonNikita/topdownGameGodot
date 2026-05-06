extends Control

@export var control: HTTP

@onready var chat_log: RichTextLabel = $PanelContainer/VBoxContainer/ChatLog
@onready var input: LineEdit = $PanelContainer/VBoxContainer/HBoxContainer/Input
@onready var send_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/SendButton

#var current_npc: Node = null

func _ready() -> void:
	hide()

	send_button.pressed.connect(_on_send_pressed)
	input.text_submitted.connect(_on_text_submitted)

	control.response_received.connect(_on_response_received)

#npc: Node
func open_dialog() -> void:
	#current_npc = npc
	Global.is_dialog = true
	show()
	input.grab_focus()
	add_message("NPC", "привет") #npc.get_dialog_greeting()


func close_dialog() -> void:
	Global.is_dialog = false
	hide()
	#current_npc = null
	#chat_log.clear()


func _on_send_pressed() -> void:
	send_message()


func _on_text_submitted(text: String) -> void:
	send_message()


func send_message() -> void:
	var text := input.text.strip_edges()

	if text == "":
		return

	add_message("You", text)
	input.clear()

	# просто отправляем запрос
	control.test_single_request(text)


func add_message(sender: String, text: String) -> void:
	chat_log.append_text("[b]%s:[/b] %s\n" % [sender, text])
	chat_log.scroll_to_line(chat_log.get_line_count())


func _on_response_received(response: String) -> void:
	add_message("NPC", response)
