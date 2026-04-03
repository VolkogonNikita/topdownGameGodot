extends Node
class_name ArenaTimeManager

@export var end_screen_scene: PackedScene
@export var game_length: float = 10

@onready var timer = $Timer

signal difficulty_increased(difficulty_level: int) 
signal first_quest_started()
signal first_quest_ended()
signal second_quest_started()
signal second_quest_ended()

var difficulty_level: int = 1
var current_quest: int = 0
var is_first_quest_finished: bool = false
var is_second_quest_finished: bool = false

func _ready():
	add_to_group("arena_time_manager")
	process_mode = Node.PROCESS_MODE_DISABLED
	# Подключаем сигнал таймера (раскомментировано!)
	#timer.timeout.connect(_on_timer_timeout)

func start_first_quest():
	if current_quest != 0:
		return
	
	print("start_first_quest() вызван")
	current_quest = 1
	process_mode = Node.PROCESS_MODE_INHERIT
	timer.start(game_length)
	first_quest_started.emit()
	print("Квест 1 начался, таймер запущен, time_left=", timer.time_left)

func start_second_quest():
	if not is_first_quest_finished or is_second_quest_finished:
		print("Не удалось запустить второй квест: first_finished=", is_first_quest_finished, " second_finished=", is_second_quest_finished)
		return
	
	if current_quest != 0:
		print("Квест уже активен: current_quest=", current_quest)
		return
	
	print("start_second_quest() вызван")
	
	# Останавливаем старый таймер если он работает
	if not timer.is_stopped():
		timer.stop()
	
	current_quest = 2
	difficulty_level = 2
	difficulty_increased.emit(difficulty_level)
	
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# Запускаем таймер заново
	timer.start(game_length)
	second_quest_started.emit()
	print("Квест 2 начался, таймер запущен, time_left=", timer.time_left)

func _on_timer_timeout() -> void:
	print("_on_timer_timeout() вызван, current_quest=", current_quest)
	
	match current_quest:
		1:
			current_quest = 0
			is_first_quest_finished = true
			first_quest_ended.emit()
			print("Квест 1 закончен")
		
		2:
			current_quest = 0
			is_second_quest_finished = true
			second_quest_ended.emit()
			print("Квест 2 закончен")
	
	timer.stop()
	process_mode = Node.PROCESS_MODE_DISABLED

func get_time_elapsed():
	if current_quest == 0:
		return 0.0
	
	# Убеждаемся, что таймер активен
	if timer.is_stopped():
		print("ВНИМАНИЕ: таймер остановлен, но квест активен!")
		return 0.0
	
	var elapsed = game_length - timer.time_left
	return elapsed

# Эта функция больше не нужна, удалите её или закомментируйте
# func force_update_timer():
#     pass
