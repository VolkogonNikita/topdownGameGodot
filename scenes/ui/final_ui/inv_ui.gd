extends Control

@onready var inv: Inv = preload("res://scenes/ui/final_ui/items/players_inventory.tres")
@export var health_component: HealthComponent
@export var stamina_component: StaminaComponent
@export var exp_component: ExperienceManager

var is_open: bool = false

func _ready() -> void:
	close()


func _process(delta: float) -> void:
	$HealthValueLabel.text = str(health_component.current_health) + "/" + str(health_component.max_health)
	$StaminaValueLabel.text = "%.0f/%.0f" % [stamina_component.current_stamina, stamina_component.max_stamina]
	$ExpValueLabel.text = str(exp_component.current_experience) + "/" + str(exp_component.target_experience)
	$LevelLabel.text = str(exp_component.current_level) + " lvl"
	if Input.is_action_just_pressed("tab"):
		if is_open: close()
		else: open()


func open():
	print("open")
	self.is_open = true
	visible = true


func close():
	print("close")
	is_open = false
	visible = false
