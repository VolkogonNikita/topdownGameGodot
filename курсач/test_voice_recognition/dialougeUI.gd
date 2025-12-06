extends CanvasLayer

signal user_sent_message(text)
@onready var input = $VBoxContainer/LineEdit
var is_open := false

func _ready():
	visible = false
	
func open():
	is_open = true
	visible = true
	input.text = ""
	input.grab_focus()
	
func close():
	is_open = false
	visible = false

func _process(delta: float) -> void:
	if is_open and Input.is_action_just_pressed("ui_accept"):
		if input.text.strip() != "":
			emit_signal("user_sent_message", input.text)
			close()
