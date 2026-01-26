extends Node

@export var max_speed: int = 50
@export var acceleration: float = 5

var current_velocity = Vector2.ZERO

func move_to_player(mob: CharacterBody2D):
	var direction = get_direction()
	var velocity = acceleration_to_direction(direction)
	mob.velocity = velocity
	mob.move_and_slide()

func get_direction():
	var mob = owner as Node2D
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2(0,0)


func acceleration_to_direction(direction: Vector2):
	var final_velocity = max_speed * direction
	current_velocity = current_velocity.lerp(final_velocity, 1 - exp(-acceleration * get_process_delta_time()))
	return current_velocity
