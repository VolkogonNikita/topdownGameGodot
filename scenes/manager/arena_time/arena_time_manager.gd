#added to diagram
extends Node
class_name ArenaTimeManager

@export var end_screen_scene: PackedScene
@export var game_length:float = 60

@onready var timer = $Timer
@onready var difficulty_timer = $DifficultyTimer

signal difficulty_increased(difficulty_level: int) 
signal quest_started()
signal quest_ended()

var difficulty_level: int = 0
var is_quest_active: bool = false
var is_quest_finished: bool = false

func _ready():
	add_to_group("arena_time_manager")
	#timer.start(game_length)
	process_mode = Node.PROCESS_MODE_DISABLED


func start_game():
	if is_quest_active:
		return
	is_quest_active = true
	process_mode = Node.PROCESS_MODE_INHERIT
	timer.start(game_length)
	difficulty_timer.start()
	quest_started.emit()
	print("Квест начался")

func gold_to_add():
	#floor - округление в меньшую сторону, round - в большую
	return floor(get_time_elapsed() / 10)


func get_time_elapsed():
	return game_length - timer.time_left if is_quest_active else 0

	
func _on_timer_timeout() -> void:
	if not is_quest_active:
		return
	#var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	#get_parent().add_child(end_screen_instance)
	#end_screen_instance.change_to_victory()
	#end_screen_instance.update_gold_to_add(gold_to_add())
	#end_screen_instance.play_jingle(1)
	is_quest_active = false
	is_quest_finished = true
	quest_ended.emit()
	timer.stop()

func _on_difficulty_timer_timeout() -> void:
	if not is_quest_active:
		return
	difficulty_level += 1
	difficulty_increased.emit(difficulty_level)
