extends Node2D

@onready var label = $Label
@onready var animation_player = $AnimationPlayer

func damage_text(damage):
	label.text = str(damage)
	animation_player.play("damage_text")
