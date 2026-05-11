extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time: Label = $CanvasLayer/time
@onready var rain: Rain = $CanvasLayer/Rain

var player = null
var player_quest: bool = false
var pause_menu_scene = preload("res://scenes/ui/pause_menu/pause_menu.tscn")
var puddle_scene = preload("res://scenes/level/world/puddle.tscn")
var slug_scene = preload("res://scenes/game_objects/enemies/slug/slug.tscn")

@export var puddle_lifetime: float = 10   
@export var spawn_delay: float = 0.03     
@export var puddle_max_count: int = 1000   

var go_rain: bool
var puddle_count = 0
var puddle_timer: float = 0.0
var slug_count = 0

@export var spawn_position_after_dungeon: Vector2 = Vector2(1008, 304)
var position_set: bool = false
var python_process = null

func _ready() -> void:
	#start_python_server()
	rain.is_raining.connect(on_is_raining)
	rain.isnt_raining.connect(on_isnt_raining)
	MusicPlayer.play()
	
	# Пытаемся найти игрока сразу
	find_player()
	
	# Устанавливаем позицию с задержкой для надёжности
	if Global.was_in_dungeon:
		print("Вернулись из подземелья! Перемещаем игрока к входу...")
		call_deferred("set_player_position_deferred")
		$Environment1/Door/Area2D.monitorable = false
		$Environment1/Door/Area2D.monitoring = false
		Global.was_in_dungeon = false


func _process(delta: float) -> void:
	if Global.was_in_dungeon and not position_set and player:
		set_player_position()
		Global.was_in_dungeon = false
	
	animation_player.play("day-night")
	
	is_raining()
	
	if player_quest: 
		if Input.is_action_just_pressed("action"):
			await get_tree().create_timer(0.5).timeout
			MetaProgression.save_state()
			MetaProgression.request_load()
			get_tree().change_scene_to_file("res://scenes/level/floor.tscn")


func find_player() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player:
		print("Игрок найден в world: ", player.global_position)


func set_player_position():
	if not player:
		find_player()
	
	if player:
		player.global_position = spawn_position_after_dungeon
		# Сбрасываем velocity
		if player is CharacterBody2D:
			player.velocity = Vector2.ZERO
		
		# Сбрасываем камеру если есть
		var camera = player.find_child("Camera2D", true, false)
		if camera:
			camera.reset_smoothing()
		
		position_set = true
		print("Позиция игрока установлена: ", player.global_position)


func set_player_position_deferred():
	# Небольшая задержка чтобы все _ready() отработали
	await get_tree().process_frame
	set_player_position()
	
	# Дополнительная проверка через 0.1 секунды
	await get_tree().create_timer(0.1).timeout
	if player and player.global_position.distance_to(spawn_position_after_dungeon) > 10:
		print("Позиция сбилась! Переустанавливаем...")
		set_player_position()


func spawn_puddle():
	var puddle = puddle_scene.instantiate()
	puddle.position = Vector2(randf_range(-1000, 2000), randf_range(-1000,2000))
	add_child(puddle)
	puddle_count += 1
	var timer = get_tree().create_timer(puddle_lifetime)
	timer.timeout.connect(func(): 
		if is_instance_valid(puddle): 
			puddle.queue_free() 
			puddle_count -= 1)


func spawn_slug():
	var slug = slug_scene.instantiate()
	slug.position = Vector2(randf_range(-256, 500), randf_range(0,512))
	if slug_count < 5:
		add_child(slug)
		slug_count += 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_quest = true
		print("Игрок вошёл в зону world ", player_quest)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_quest = false
		print("Игрок вышел из зоны world ", player_quest)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())


func morning():
	$CanvasLayer/time.text = "time: morning"
	$Environment1/PointLight2D.energy = 0.0
	$Environment1/PointLight2D2.energy = 0.0
	$Environment1/PointLight2D3.energy = 0.0
	$Environment1/PointLight2D4.energy = 0.0
	$Environment1/PointLight2D5.energy = 0.0


func day():
	$CanvasLayer/time.text = "time: day"


func evening():
	$CanvasLayer/time.text = "time: evening"
	$Environment1/PointLight2D.energy = 1.0
	$Environment1/PointLight2D2.energy = 1.0
	$Environment1/PointLight2D3.energy = 1.0
	$Environment1/PointLight2D4.energy = 1.0
	$Environment1/PointLight2D5.energy = 1.0


func night():
	$CanvasLayer/time.text = "time: night"


func is_raining():
	if go_rain:
		spawn_puddle()
		spawn_slug()
	else: 
		slug_count = 0
		return


func on_is_raining():
	go_rain = true


func on_isnt_raining():
	go_rain = false


func on_dungeon_quest_ended():
	$Environment1/Door/Area2D.monitorable = false
	$Environment1/Door/Area2D.monitoring = false


func start_python_server():
	# Путь к Python (может отличаться в зависимости от системы)
	var python_path = "D:/учёба/диплом/RealTopDown/topdown/scripts/TrainModel/.venv/Scripts/python.exe"  # или "python3" на Linux/Mac, или полный путь "C:/Python39/python.exe"
	
	# Лучше указать абсолютный путь или скопировать скрипт в пользовательскую папку
	#var user_script_path = "D:/учёба/диплом/RealTopDown/topdown/scripts/TrainModel/.venv/main.py"
	#var user_script_path = "D:/учёба/диплом/llama/TrainModel/chat.py"
	var user_script_path = "D:/учёба/диплом/llama/TrainModel/.venv/main.py"
	# Запускаем процесс
	python_process = OS.create_process(python_path, [user_script_path])
	
	if python_process == OK:
		print("✅ Python сервер запущен")
	else:
		print("❌ Ошибка запуска Python сервера")
