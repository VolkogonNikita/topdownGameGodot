extends Node
class_name HealAbility

@export var health_component: HealthComponent
@export var stamina_component: StaminaComponent

@export var heal = 10
@export var stamina_cost = 40
@export var bonus_heal_per_level = 2 
@export var bonus_stamina_per_level = 10

@onready var timer: Timer = $Timer

var is_on_cooldown = false

func _ready() -> void:
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(on_cooldown_finished)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("heal"):
		perform_heal()


func perform_heal():
	if is_on_cooldown:
		return
		
	health_component.take_heal(heal)
	stamina_component.use_stamina(stamina_cost)
	var player = get_tree().get_first_node_in_group("player")
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.global_position = player.global_position
	start_cooldown()


func start_cooldown():
	is_on_cooldown = true
	timer.start()


func on_cooldown_finished():
	is_on_cooldown = false
	print("Лечение готово")
