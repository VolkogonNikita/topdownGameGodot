extends Node2D

#var player = get_tree().get_first_node_in_group("player")

func _on_area_2d_area_entered(_area: Area2D) -> void:
	queue_free()

 
