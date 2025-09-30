extends CharacterBody2D

var SPEED = 200
var acceleration = .15

func _process(_delta: float) -> void:
	var direction = movement_vector().normalized()
	var target_velocity = SPEED * direction
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()

func movement_vector():
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	return Vector2(movement_x, movement_y)
	
