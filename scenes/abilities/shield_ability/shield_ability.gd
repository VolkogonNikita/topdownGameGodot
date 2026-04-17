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

var is_on_cooldown = false
var is_shield_active = false
var player: Player = null

signal shield_is_active

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
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
	
	shield_is_active.emit()
	
	global_position = player.global_position
	
	if shield_visual:
		shield_visual.visible = true
		if animated_sprite_2d:
			animated_sprite_2d.play("default")

	#var grace_period = player.find_child("GracePeriod")
	#grace_period = shield_duration
	#var grace_period = player.get_node("GracePeriod")
	#
	#PLAYER.check_if_damaged(shield_duration)
	#player.check_if_damaged(shield_duration)
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

	print("Щит деактивирован")
