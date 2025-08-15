extends CharacterBody2D

#var SKELETON_STATE = "run"
var SKELETON_SPEED = 50
#var player = null
#var player_in_area = false

func _process(delta: float) -> void:
	var direction = get_direction_to_player()
	velocity = SKELETON_SPEED * direction#*delta
	move_and_slide()
	#state()

#func state():
	#if SKELETON_STATE == "idle":
		#$AnimatedSprite2D.play("skeleton_idle")
	#else:
		#$AnimatedSprite2D.play("skeleton_run")

func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		return (player.global_position - self.global_position).normalized()
	return Vector2.ZERO
