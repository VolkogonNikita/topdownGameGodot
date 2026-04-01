extends Node2D

var player = null
#@onready var player: Player = $Player

func _process(delta: float) -> void:
	if player: 
		print(1)
		if Input.is_action_just_pressed("action"):
			get_tree().change_scene_to_file("res://scenes/level/floor.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print(2)
		player = body 


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
	print(3)
