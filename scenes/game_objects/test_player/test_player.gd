extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var arena_time_manager: ArenaTimeManager
@onready var label: Label = $Label

var player = null


func _ready():
	if arena_time_manager:
		arena_time_manager.quest_ended.connect(on_quest_ended)
	label.visible = false
	label.text = "press e to start"
	animated_sprite_2d.play("idle")   


func _process(delta: float) -> void:
	if player:
		label.visible = true
		if Input.is_action_just_pressed("action") and !arena_time_manager.is_quest_finished:
			label.text = "Ебашь долбаёбов!"
			start_quest()
	if !player:
		label.visible = false


func start_quest():
	if arena_time_manager: #and not arena_time_manager.is_game_active:
		arena_time_manager.start_game()


func on_quest_ended():
	label.text = "Thank u"


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("quest")
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
