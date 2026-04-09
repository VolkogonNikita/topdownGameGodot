#added to diagram
extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var movement_component = $MovementComponent
@onready var attack_timer: Timer = $AttackTimer
@onready var fireball_spawner: Node2D = $FireballSpawner
@onready var player = null

@export var death_scene: PackedScene
@export var fireball_scene: PackedScene
@export var sprite: CompressedTexture2D

enum Phase {
	Phase_1,
	Phase_2
}

var base_speed
var attack_range = false
var current_phase = Phase.Phase_1
var original_scale: Vector2

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	base_speed = movement_component.max_speed
	original_scale = scale
	health_component.died.connect(on_died)
	health_component.get_damage.connect(_on_health_component_health_decreased)
	
	# Важно: отключаем автоматическое движение в компоненте, если оно есть
	# или настраиваем его на ручное управление

func _physics_process(_delta: float) -> void:
	# Двигаемся только если не в зоне атаки
	if not attack_range:
		movement_component.move_to_player(self)
	else:
		# Останавливаемся, если в зоне атаки
		velocity = Vector2.ZERO
		move_and_slide()
	
	update_animations()

func update_animations():
	var direction = movement_component.get_direction()
	
	# Проверяем, движется ли моб
	if not attack_range and (direction.x != 0 || direction.y != 0):
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	# Поворот спрайта
	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

func on_died():
	var back_layer = get_tree().get_first_node_in_group("back_layer")
	var death_instance = death_scene.instantiate() as DeathComponent
	back_layer.add_child(death_instance)
	death_instance.gpu_particles_2d.texture = sprite
	death_instance.global_position = global_position
	queue_free()

func check_phase():
	if health_component.current_health <= health_component.max_health / 2 and current_phase != Phase.Phase_2:
		print("Phase 2")
		current_phase = Phase.Phase_2
		movement_component.max_speed = base_speed * 1.5  # Используем movement_component.max_speed
		attack_timer.wait_time = 1.0  # Уменьшаем задержку между атаками
		scale = original_scale * 1.5

func single_shot():
	if not player or not is_instance_valid(player):
		return
		
	var front_layer = get_tree().get_first_node_in_group("front_layer")
	var fireball_instance = fireball_scene.instantiate()
	front_layer.add_child(fireball_instance)
	fireball_instance.global_position = fireball_spawner.global_position
	
	var direction = (player.global_position - global_position).normalized()
	fireball_instance.direction = direction
	fireball_instance.rotation = direction.angle()

func burst_shot():
	# Три выстрела с задержкой
	for i in range(3):
		if not attack_range:  # Если вышел из зоны атаки, прерываем
			break
		if player and is_instance_valid(player):
			single_shot()
		await get_tree().create_timer(0.2).timeout

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		attack_range = true
		movement_component.max_speed = 0
		# Останавливаем движение немедленно
		velocity = Vector2.ZERO

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		attack_range = false
		movement_component.max_speed = movement_component.slow_speed if movement_component.has_method("get_current_speed") else base_speed

func _on_attack_timer_timeout() -> void:
	if not player or not is_instance_valid(player):
		return
		
	if attack_range:
		match current_phase:
			Phase.Phase_1:
				single_shot()
			Phase.Phase_2:
				burst_shot()

func _on_health_component_health_decreased() -> void:
	check_phase()
