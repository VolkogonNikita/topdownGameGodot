extends Node2D

@onready var label = $Label
@onready var animation_player = $AnimationPlayer

func damage_text(damage):
	var text_format = "%0.1f"
	if damage == round(damage):
		text_format = "%0.0f"
	label.text = (text_format % damage)
	animation_player.play("damage_text")
