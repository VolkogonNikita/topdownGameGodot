#added to diagram
extends CharacterBody2D

var SPEED = 200
var acceleration = .15
var PLAYER_STATE = "idle"

func _process(_delta: float) -> void:
	var direction = movement_vector().normalized()
	var target_velocity = SPEED * direction
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()

func movement_vector():
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	return Vector2(movement_x, movement_y)
	
func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_down","move_left","move_right","move_up")
	
	if direction.x == 0 and direction.y == 0:
		PLAYER_STATE == "idle"
	else:
		PLAYER_STATE == "run"
	play_anim()

func play_anim():
	if PLAYER_STATE == "idle":
		$AnimatedSprite2D.play("idle")
	else: 
		if PLAYER_STATE == "run":
			$AnimatedSprite2D.play("run")
