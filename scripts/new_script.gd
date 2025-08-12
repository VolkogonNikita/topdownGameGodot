extends Node

var PLAYER_STATE = "idle"

func _ready() -> void:
	print("1")
	pass

func _physics_process(delta: float) -> void:
	russian_rap()
	print(1)

func _process(delta: float) -> void:
	russian_rap()
	print(2)

func russian_rap():
	if PLAYER_STATE == "idle":
		$AnimatedSprite2D.play("idle")
	print(1)
