extends Control

var is_open: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("b"):
		if is_open: close()
		else: open()


func open():
	is_open = true
	visible = true


func close():
	is_open = false
	visible = false
