extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var arena_time_manager: ArenaTimeManager
@onready var label: Label = $Label

var player = null

func _ready():
	label.visible = false
	label.text = "press e to start"
	animated_sprite_2d.play("idle")   


func _process(delta: float) -> void:
	if player:
		label.visible = true
		if Input.is_action_just_pressed("e"):
			start_game()
	if !player:
		label.visible = false


func start_game():
	if arena_time_manager: #and not arena_time_manager.is_game_active:
		print("1")
		arena_time_manager.start_game()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
