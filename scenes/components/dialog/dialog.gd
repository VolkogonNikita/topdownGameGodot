extends Control

@export var control: HTTP

@onready var chat_log: RichTextLabel = $PanelContainer/VBoxContainer/ChatLog
@onready var input: LineEdit = $PanelContainer/VBoxContainer/HBoxContainer/Input
@onready var send_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/SendButton

func _ready() -> void:
	hide()

	send_button.pressed.connect(_on_send_pressed)
	input.text_submitted.connect(_on_text_submitted)

	control.response_received.connect(_on_response_received)

func open_dialog() -> void:
	Global.is_dialog = true
	show()
	input.grab_focus()
	add_message("NPC", "привет") 


func close_dialog() -> void:
	Global.is_dialog = false
	hide()


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

	control.send_message(text)


func add_message(sender: String, text: String) -> void:
	chat_log.append_text("[b]%s:[/b] %s\n" % [sender, text])
	chat_log.scroll_to_line(chat_log.get_line_count())


func _on_response_received(npc_name:String, response: String) -> void:
	add_message(npc_name, response)
