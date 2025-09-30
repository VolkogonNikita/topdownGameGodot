extends Node

var skeleton_scene = preload("res://scenes/game_objects/enemies/skeleton/skeleton.tscn")

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player:
		return 
	
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var random_distance = randi_range(370,500)
	#var spawn_pos = player.global_position + random_direction * random_distance
	
	var enemy = skeleton_scene.instantiate() as Node2D
	get_parent().add_child(enemy)
	
	enemy.global_position = player.global_position + random_direction * random_distance
