#added to diagram
extends Node
class_name ArenaTimeManager

@export var end_screen_scene: PackedScene
@export var game_length:float = 600

@onready var timer = $Timer
@onready var difficulty_timer = $DifficultyTimer

signal difficulty_increased(difficulty_level: int) 

var difficulty_level: int = 0

func _ready():
	timer.start(game_length)


func gold_to_add():
	#floor - округление в меньшую сторону, round - в большую
	return floor(get_time_elapsed() / 10)


func get_time_elapsed():
	return game_length - timer.time_left

	
func _on_timer_timeout() -> void:
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	get_parent().add_child(end_screen_instance)
	end_screen_instance.change_to_victory()
	end_screen_instance.update_gold_to_add(gold_to_add())
	end_screen_instance.play_jingle(1)

func _on_difficulty_timer_timeout() -> void:
	difficulty_level += 1
	difficulty_increased.emit(difficulty_level)
