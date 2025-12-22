#added to diagram
extends Node
class_name ArenaTimeManager

@export var end_screen_scene: PackedScene

@onready var timer = $Timer
@onready var difficulty_timer = $DifficultyTimer

signal difficulty_increased(difficulty_level: int) 

var difficulty_level: int = 0

func get_time_elapsed():
	return $Timer.wait_time - $Timer.time_left

func _on_timer_timeout() -> void:
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	get_parent().add_child(end_screen_instance)
	end_screen_instance.change_to_victory()

func _on_difficulty_timer_timeout() -> void:
	difficulty_level += 1
	difficulty_increased.emit(difficulty_level)
