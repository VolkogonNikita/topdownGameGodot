extends Node

@export var max_speed: float = 200.0
@export var slow_speed: float = 100.0  # Скорость без стамины
@export var acceleration: float = 5.0

var current_velocity = Vector2.ZERO
var stamina_component: StaminaComponent
var current_max_speed: float

func _ready():
	current_max_speed = max_speed
	# Ищем компонент стамины у владельца
	stamina_component = owner.get_node_or_null("StaminaComponent")
	if stamina_component:
		stamina_component.stamina_depleted.connect(_on_stamina_depleted)
		stamina_component.stamina_recovered.connect(_on_stamina_recovered)

func move_to_player(mob: CharacterBody2D):
	var direction = get_direction()
	var velocity = acceleration_to_direction(direction)
	mob.velocity = velocity
	mob.move_and_slide()

func get_direction():
	var mob = owner as Node2D
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2(0,0)

func acceleration_to_direction(direction: Vector2):
	var final_velocity = get_current_speed() * direction
	current_velocity = current_velocity.lerp(final_velocity, 1 - exp(-acceleration * get_process_delta_time()))
	return current_velocity

func get_current_speed() -> float:
	# Если есть стамина и персонаж бежит
	if stamina_component and stamina_component.is_running and stamina_component.has_stamina():
		return max_speed
	else:
		return slow_speed

func _on_stamina_depleted():
	print("Stamina depleted! Slowing down...")

func _on_stamina_recovered():
	print("Stamina recovered! Speed restored...")

func set_running(is_running: bool):
	if stamina_component:
		if is_running:
			stamina_component.start_running()
		else:
			stamina_component.stop_running()
