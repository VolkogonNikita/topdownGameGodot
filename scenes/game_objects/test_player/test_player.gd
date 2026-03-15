extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var player = null

func _ready():
	animated_sprite_2d.play("idle")


func _process(delta: float) -> void:
	if player:
		print("is Player")
	if !player:
		print("not player")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
