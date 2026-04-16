extends Node2D

@export var health_component: HealthComponent
@export var stamina_component: StaminaComponent
@export var shield_duration: float = 5.0
@export var stamina_cost: float = 50.0
@export var shield_radius: float = 50.0

@onready var timer: Timer = $Timer
@onready var shield_timer: Timer = $ShieldTimer
@onready var shield_visual: Node2D = $ShieldVisual
@onready var animated_sprite_2d: AnimatedSprite2D = $ShieldVisual/AnimatedSprite2D
@onready var shield_static_body: StaticBody2D = $ShieldStaticBody2D
@onready var collision_shape: CollisionShape2D = $ShieldStaticBody2D/CollisionShape2D

var is_on_cooldown = false
var is_shield_active = false
var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("Не найден игрок в группе 'player'!")
		return

	# Таймер кулдауна
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(on_cooldown_finished)

	# Таймер длительности щита
	shield_timer.autostart = false
	shield_timer.one_shot = true
	shield_timer.wait_time = shield_duration
	shield_timer.timeout.connect(deactive_shield)

	# Настройка коллизии
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = shield_radius
		collision_shape.disabled = true
	
	# ВАЖНО: Отключаем коллизию с игроком через слои
	if shield_static_body:
		# Ставим слой щита, но НЕ маску игрока
		shield_static_body.collision_layer = 32  # Слой 6 для щита
		shield_static_body.collision_mask = 2    # Только слой врагов (слой 2)

	if shield_visual:
		shield_visual.visible = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("4"):
		perform_shield()
	
	if is_shield_active and player:
		global_position = player.global_position


func perform_shield():
	if is_on_cooldown or is_shield_active:
		return

	if stamina_component:
		stamina_component.use_stamina(stamina_cost)

	is_shield_active = true
	
	global_position = player.global_position
	
	if shield_visual:
		shield_visual.visible = true
		if animated_sprite_2d:
			animated_sprite_2d.play("default")

	if collision_shape:
		collision_shape.disabled = false

	shield_timer.start()
	start_cooldown()


func start_cooldown():
	is_on_cooldown = true
	timer.start()


func on_cooldown_finished():
	is_on_cooldown = false
	print("Щит готов к использованию")


func deactive_shield():
	is_shield_active = false

	if shield_visual:
		shield_visual.visible = false

	if collision_shape:
		collision_shape.disabled = true

	print("Щит деактивирован")
