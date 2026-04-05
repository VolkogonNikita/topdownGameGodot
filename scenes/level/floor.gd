extends Node

@export var end_screen_scene: PackedScene
@export var arena_time_manager: ArenaTimeManager

@onready var player = $Back/player
@onready var lever_animated_sprite_2d: AnimatedSprite2D = $environment/LeverAnimatedSprite2D

var player_exit = null
var player_quest = null
var pause_menu_scene = preload("res://scenes/ui/pause_menu/pause_menu.tscn")

func _ready():
	#$environment/EnemyHitBox.visible = false
	MusicPlayer.play()
	player.health_component.died.connect(on_died)
	
	# Подключаем сигналы окончания квестов
	if arena_time_manager:
		arena_time_manager.first_quest_ended.connect(on_first_quest_ended)
		arena_time_manager.second_quest_ended.connect(on_second_quest_ended)

func _process(delta: float) -> void:
	if player_exit:
		if Input.is_action_just_pressed("action"):
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://scenes/level/world/world.tscn")
	
	if player_quest:
		# Первый квест
		if Input.is_action_just_pressed("action") and not arena_time_manager.is_first_quest_finished and arena_time_manager.current_quest == 0:
			$environment/LeverAnimatedSprite2D.play("center")
			start_first_quest()
		
		# Второй квест - исправленное условие
		elif Input.is_action_just_pressed("action") and arena_time_manager.is_first_quest_finished and not arena_time_manager.is_second_quest_finished and arena_time_manager.current_quest == 0:
			$environment/LeverAnimatedSprite2D.play("down")
			start_second_quest()


func on_died():
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	add_child(end_screen_instance)
	#end_screen_instance.update_gold_to_add(arena_time_manager.gold_to_add())
	end_screen_instance.play_jingle()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())	


func _on_exit_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("exit")
		player_exit = body


func _on_exit_area_2d_body_exited(body: Node2D) -> void:
	player_exit = null


func start_first_quest():
	if arena_time_manager:
		arena_time_manager.start_first_quest()


func start_second_quest():
	if arena_time_manager:
		arena_time_manager.start_second_quest()


func on_first_quest_ended():
	print("Первый квест завершён! Можно активировать второй квест")


func on_second_quest_ended():
	print("Второй квест завершён! Игра окончена")
	$Back/DoorCharacterBody2D/DoorAnimatedSprite2D.play("open")
	$Back/DoorCharacterBody2D/CollisionShape2D.disabled = true
	# Можно показать экран победы или что-то ещё


func _on_lever_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("quest")
		player_quest = body


func _on_lever_area_2d_body_exited(body: Node2D) -> void:
	player_quest = null


func _on_enemy_hit_box_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(0.2)
	$environment/EnemyHitBox/TrapTileMapLayer.visible = true


func _on_enemy_hit_box_body_exited(body: Node2D) -> void:
	await get_tree().create_timer(0.2)
	$environment/EnemyHitBox/TrapTileMapLayer.visible = false
