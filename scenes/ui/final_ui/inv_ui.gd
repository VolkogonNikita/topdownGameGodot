extends Control
class_name InvUI

@onready var enhance_skills_button: Button = $EnhanceSkillsButton

@export var health_component: HealthComponent
@export var stamina_component: StaminaComponent
@export var exp_component: ExperienceManager

var is_open: bool = false
signal enhance_skills_button_pressed

func _ready() -> void:
	exp_component.level_up.connect(on_level_up)
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


func on_level_up():
	enhance_skills_button.disabled = false


func _on_enhance_skills_button_pressed() -> void:
	enhance_skills_button_pressed.emit()
	enhance_skills_button.disabled = true
