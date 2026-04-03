extends StaticBody2D

@export var arena_time_manager: ArenaTimeManager

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	$CollisionShape2D.disabled = true
	if arena_time_manager:
		arena_time_manager.first_quest_ended.connect(on_first_quest_ended)
		arena_time_manager.first_quest_started.connect(on_first_quest_started)


func on_first_quest_started():
	$CollisionShape2D.disabled = false
	sprite_2d.texture = load("res://assets/result/open_hatch.png")
	pass


func on_first_quest_ended():
	$CollisionShape2D.disabled = true
	sprite_2d.texture = load("res://assets/result/closed_hatch.png")
	pass
