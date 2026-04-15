# shield_ability_simple.gd
extends Node

@export var stamina_component: StaminaComponent
@export var shield_duration: float = 5.0
@export var shield_scene: PackedScene

@onready var timer: Timer = $Timer
@onready var shield_timer: Timer = $ShieldTimer

var is_on_cooldown = false
var is_shield_active = false
var active_shield_instance: Node2D = null

func _ready() -> void:
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(func(): is_on_cooldown = false)
	
	if not shield_timer:
		shield_timer = Timer.new()
		add_child(shield_timer)
	
	shield_timer.autostart = false
	shield_timer.one_shot = true
	shield_timer.timeout.connect(deactivate_shield)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("4") and not is_on_cooldown:
		perform_shield()

func perform_shield():
	if not stamina_component.has_stamina():
		return
	
	# Активируем щит
	is_shield_active = true
	
	# Создаём визуальный щит
	if shield_scene:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			active_shield_instance = shield_scene.instantiate()
			player.add_child(active_shield_instance)
	
	# Включаем коллизию
	var player = get_tree().get_first_node_in_group("player")
	var shield_area = player.find_child("ShieldArea2D", true, false)
	if shield_area:
		shield_area.monitoring = true
		shield_area.monitorable = true
	
	# Тратим стамину и запускаем таймеры
	stamina_component.use_stamina(50)
	shield_timer.start(shield_duration)
	
	# Кулдаун
	is_on_cooldown = true
	timer.start()

func deactivate_shield():
	is_shield_active = false
	
	# Убираем щит
	if active_shield_instance:
		active_shield_instance.queue_free()
		active_shield_instance = null
	
	# Выключаем коллизию
	var player = get_tree().get_first_node_in_group("player")
	var shield_area = player.find_child("ShieldArea2D", true, false)
	if shield_area:
		shield_area.monitoring = false
		shield_area.monitorable = false

func is_shield_up() -> bool:
	return is_shield_active
