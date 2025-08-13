extends CharacterBody2D

var SPEED = 200
var PLAYER_STATE = "idle"

func method_player():
	pass

func _process(delta: float) -> void:
	russian_rap()
	var direction = movement_vector().normalized()
	velocity = SPEED * direction
	move_and_slide()

func movement_vector():
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	PLAYER_STATE = ""
	return Vector2(movement_x, movement_y)
	
func russian_rap():
	if PLAYER_STATE == "idle":
		$AnimatedSprite2D.play("idle")
	##################
	else: 
		$AnimatedSprite2D.play("run")
