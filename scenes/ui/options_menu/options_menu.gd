extends CanvasLayer

@onready var window_mode_button: Button = %WindowModeButton

func _ready():
	update_options()


func update_options():
	if DisplayServer.window_get_mode() \
	== DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_mode_button.text = "Fullscreen"
	else:
		window_mode_button.text = "Windowed"


func _on_window_mode_button_pressed() -> void:
	#window mode request 
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_options()
