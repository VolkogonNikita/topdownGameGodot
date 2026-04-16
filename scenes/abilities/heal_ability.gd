extends Node

@export var health_component: HealthComponent
@export var stamina_component: StaminaComponent
@onready var timer: Timer = $Timer

var is_on_cooldown = false

func _ready() -> void:
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(on_cooldown_finished)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("3"):
		perform_heal()


func perform_heal():
	if is_on_cooldown:
		return
		
	health_component.take_heal(10)
	stamina_component.use_stamina(40)
	start_cooldown()


func start_cooldown():
	is_on_cooldown = true
	timer.start()


func on_cooldown_finished():
	is_on_cooldown = false
	print("Лечение готово")
