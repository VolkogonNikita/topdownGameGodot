extends CharacterBody2D

var SKELETON_SPEED = 50

func _process(_delta: float) -> void:
	var direction = get_direction_to_player()
	velocity = SKELETON_SPEED * direction#*delta
	move_and_slide()

func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		return (player.global_position - self.global_position).normalized()
	return Vector2.ZERO

func _on_area_2d_area_entered(_area: Area2D) -> void:
	queue_free()
