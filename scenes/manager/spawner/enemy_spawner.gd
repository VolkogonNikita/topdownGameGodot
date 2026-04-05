extends Node

@export var arena_time_manager: ArenaTimeManager
@export var skeleton_scene: PackedScene 
@export var goblin_scene: PackedScene
@export var imp_scene: PackedScene
@export var mini_boss_scene: PackedScene

@onready var timer = $Timer

var base_spawn_time
var min_spawn_time = 0.2
var difficulty_multiplier = 0.01
var enemy_pool = EnemyPool.new()
var is_spawning_active: bool = false
var current_spawn_area: String = ""

func _ready():
	if arena_time_manager:
		setup_enemy_pool_for_first_quest()  # Настраиваем пул для первого квеста
		base_spawn_time = timer.wait_time
		arena_time_manager.difficulty_increased.connect(on_difficulty_increased)
		arena_time_manager.first_quest_started.connect(on_first_quest_started)
		arena_time_manager.first_quest_ended.connect(on_first_quest_ended)
		arena_time_manager.second_quest_started.connect(on_second_quest_started)
		arena_time_manager.second_quest_ended.connect(on_second_quest_ended)
		timer.stop()
		set_process(false)
		#timer.timeout.connect(_on_timer_timeout)

func setup_enemy_pool_for_first_quest():
	# Создаем новый пул для первого квеста
	enemy_pool = EnemyPool.new()
	enemy_pool.add_mob(skeleton_scene, 3)
	print("Пул врагов для первого квеста настроен (только скелеты)")

func setup_enemy_pool_for_second_quest():
	# Создаем новый пул для второго квеста
	enemy_pool = EnemyPool.new()
	enemy_pool.add_mob(goblin_scene, 7)  # Только гоблины
	print("Пул врагов для второго квеста настроен (только гоблины)")
	

func setup_enemy_pool_for_third_quest():
	enemy_pool = EnemyPool.new()
	enemy_pool.add_mob(imp_scene, 10)
	enemy_pool.add_mob(mini_boss_scene, 3)

#don't use it in this time
func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var random_distance = randi_range(370,500)
	var spawn_position
	
	for i in 24:
		spawn_position = player.global_position + random_direction * random_distance
		var ray_extender = random_direction * 20
		var raycast = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + ray_extender, 1)
		var intersection = get_tree().root.world_2d.direct_space_state.intersect_ray(raycast)
		if intersection.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(15))
		
	return spawn_position

func get_spawn_position_in_area(area_rect: Rect2):
	var spawn_position = Vector2(
		randf_range(area_rect.position.x, area_rect.position.x + area_rect.size.x),
		randf_range(area_rect.position.y, area_rect.position.y + area_rect.size.y)
	)
	return spawn_position

func on_difficulty_increased(difficulty_level: int):
	print("Уровень сложности увеличен: ", difficulty_level)
	if not is_spawning_active:
		return
	
	var new_spawn_time = max(min_spawn_time, (base_spawn_time - difficulty_level * difficulty_multiplier))
	timer.wait_time = new_spawn_time
	print("Новое время спавна: ", new_spawn_time)

func on_first_quest_started():
	is_spawning_active = true
	current_spawn_area = "first"
	setup_enemy_pool_for_first_quest()  # Пересоздаем пул для первого квеста
	timer.wait_time = base_spawn_time  # Сбрасываем время спавна
	timer.start(base_spawn_time)
	set_process(true)
	print("Спавн скелетов включён")

func on_first_quest_ended():
	is_spawning_active = false
	timer.stop()
	set_process(false)
	print("Спавн выключен")

func on_second_quest_started():
	is_spawning_active = true
	current_spawn_area = "second"
	setup_enemy_pool_for_second_quest()  # Создаем новый пул только с гоблинами
	timer.wait_time = base_spawn_time  # Сбрасываем время спавна
	timer.start(base_spawn_time)
	set_process(true)
	print("Спавн гоблинов включён")

func on_second_quest_ended():
	is_spawning_active = false
	timer.stop()
	set_process(false)
	print("Спавн выключен")

func _on_timer_timeout() -> void:
	print(is_spawning_active)
	if not is_spawning_active:
		return

	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player:
		return 
		
	var chosen_mob = enemy_pool.pick_mob()
	if not chosen_mob:
		print("Ошибка: нет мобов в пуле!")
		return
		
	var enemy = chosen_mob.instantiate() as Node2D
	var back_layer = get_tree().get_first_node_in_group("back_layer")
	back_layer.add_child(enemy)
	
	# Выбираем позицию спавна в зависимости от квеста
	match current_spawn_area:
		"first":
			var first_area = Rect2(112, -70, 32, 40)
			enemy.global_position = get_spawn_position_in_area(first_area)
			print("Спавн скелета в области первого квеста")
		
		"second":
			var second_area = Rect2(-56, -70, 32, 40)
			enemy.global_position = get_spawn_position_in_area(second_area)
			print("Спавн гоблина в области второго квеста")
		
		"third":
			var third_area = Rect2()#дописать
			
