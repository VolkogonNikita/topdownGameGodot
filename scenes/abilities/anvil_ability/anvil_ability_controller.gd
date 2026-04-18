extends Node

@export var anvil_ability_scene: PackedScene
@export var anvil_damage: float = 15
@export var spawn_range: float = 100

@onready var timer: Timer = $Timer

var is_on_cooldown: bool = false

func _ready() -> void:
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(on_cooldown_finished)


func _process(delta: float) -> void:
#	if Input.is_action_just_pressed("anvil_attack"):#e
#		perform_attack()
	pass


func perform_attack():
	if is_on_cooldown:
		print("Наковальная кд")
		return
	var player = get_tree().get_first_node_in_group("player") as Node2D
	#123123123
	if !player:
		return
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spawn_position = player.global_position + (direction * randf_range(0, spawn_range))
	var raycast = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
	#intersection - dictionary
	var intersection = get_tree().root.world_2d.direct_space_state.intersect_ray(raycast)
	if !intersection.is_empty():
		spawn_position = intersection["position"]
	var anvil_ability_instance = anvil_ability_scene.instantiate()
	get_tree().get_first_node_in_group("front_layer").add_child(anvil_ability_instance)
	anvil_ability_instance.global_position = spawn_position
	anvil_ability_instance.hit_box_component.damage = anvil_damage
	
	start_cooldown()


func start_cooldown():
	is_on_cooldown = true
	timer.start()
	update_ui_cooldown(true)


func on_cooldown_finished():
	is_on_cooldown = false
	print("наковальная готова")
	update_ui_cooldown(false)


func update_ui_cooldown(on_cooldown: bool):
	pass


#func _on_timer_timeout() -> void:
	#var player = get_tree().get_first_node_in_group("player") as Node2D
	##123123123
	#if !player:
		#return
	#var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	#var spawn_position = player.global_position + (direction * randf_range(0, spawn_range))
	#var raycast = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
	##intersection - dictionary
	#var intersection = get_tree().root.world_2d.direct_space_state.intersect_ray(raycast)
	#if !intersection.is_empty():
		#spawn_position = intersection["position"]
	#var anvil_ability_instance = anvil_ability_scene.instantiate()
	#get_tree().get_first_node_in_group("front_layer").add_child(anvil_ability_instance)
	#anvil_ability_instance.global_position = spawn_position
	#anvil_ability_instance.hit_box_component.damage = anvil_damage
