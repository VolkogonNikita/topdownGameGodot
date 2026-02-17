#added to diagram
extends Node

@export var arena_time_manager: ArenaTimeManager
@export var skeleton_scene: PackedScene 
@export var goblin_scene: PackedScene
@export var imp_scene: PackedScene
@export var mini_boss_scene: PackedScene

@onready var timer = $Timer

#var skeleton_scene = preload("res://scenes/game_objects/enemies/skeleton/skeleton.tscn")

var base_spawn_time
var min_spawn_time = 0.2
var difficulty_multiplier = 0.01
var enemy_pool = EnemyPool.new()

func _ready():
	#enemy_pool.add_mob(skeleton_scene, 3)
	enemy_pool.add_mob(mini_boss_scene, 100)
	base_spawn_time = timer.wait_time
	arena_time_manager.difficulty_increased.connect(on_difficulty_increased)

func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	#var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var random_distance = randi_range(370,500)
	var spawn_position # = player.global_position + random_direction * random_distance
	
	for i in 24:
		spawn_position = player.global_position + random_direction * random_distance
		var ray_extender = random_direction * 20
		var raycast = PhysicsRayQueryParameters2D.create\
		(player.global_position, spawn_position + ray_extender, 1)
		var intersection = get_tree().root.world_2d.direct_space_state.intersect_ray(raycast)
		if intersection.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(15))
		
	return spawn_position

func on_difficulty_increased(difficulty_level: int):
	var new_spawn_time = max(min_spawn_time,(base_spawn_time - difficulty_level * difficulty_multiplier))
	timer.wait_time = new_spawn_time
	if difficulty_level == 2:
		enemy_pool.add_mob(goblin_scene, 7)
	elif difficulty_level == 4:
		enemy_pool.add_mob(imp_scene, 2)

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player:
		return 
		
	var chosen_mob = enemy_pool.pick_mob()
	var enemy = chosen_mob.instantiate() as Node2D
	var back_layer = get_tree().get_first_node_in_group("back_layer")
	#get_parent().add_child(enemy)
	back_layer.add_child(enemy)
	
	enemy.global_position = get_spawn_position()
