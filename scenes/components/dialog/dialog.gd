extends CanvasLayer

@onready var chat_log: RichTextLabel = $PanelContainer/VBoxContainer/ChatLog
@onready var input: LineEdit = $PanelContainer/VBoxContainer/HBoxContainer/Input
@onready var send_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/SendButton

var current_npc: Node = null


func _ready() -> void:
	hide()

	send_button.pressed.connect(_on_send_pressed)
	input.text_submitted.connect(_on_text_submitted)


func open_dialog(npc: Node) -> void:
	current_npc = npc
	show()
	input.grab_focus()
	add_message("NPC", npc.get_dialog_greeting())


func close_dialog() -> void:
	hide()
	current_npc = null
	chat_log.clear()


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

	if current_npc and current_npc.has_method("get_response"):
		var response = current_npc.get_response(text)
		add_message("NPC", response)


func add_message(sender: String, text: String) -> void:
	chat_log.append_text("[b]%s:[/b] %s\n" % [sender, text])
	chat_log.scroll_to_line(chat_log.get_line_count())
