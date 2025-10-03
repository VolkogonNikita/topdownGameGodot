#added to diagram
extends CharacterBody2D

var SKELETON_SPEED = 50
var SKELETON_STATE = "run"
@onready var health_component = $HealthComponent

func _process(_delta: float) -> void:
	var direction = get_direction_to_player()
	velocity = SKELETON_SPEED * direction#*delta
	move_and_slide()

func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		return (player.global_position - self.global_position).normalized()
	return Vector2.ZERO

func _physics_process(delta: float) -> void:
	if SKELETON_STATE == "run":
		$AnimatedSprite2D.play("skeleton_run")
