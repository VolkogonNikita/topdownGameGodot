extends Control
class_name InvUI

@onready var enhance_skills_button: Button = $EnhanceSkillsButton

@export var health_component: HealthComponent
@export var stamina_component: StaminaComponent
@export var exp_component: ExperienceManager

var is_open: bool = false
signal enhance_skills_button_pressed
var player: Player = null

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	exp_component.level_up.connect(on_level_up)
	close()


func _process(delta: float) -> void:
	change_labels()
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


func change_labels():
	player = get_tree().get_first_node_in_group("player")
	var damage_receiver = player.find_child("DamageReceiver", true, false)
	var attack_controller = player.find_child("AttackController", true, false)
	$HealthValueLabel.text = str(health_component.current_health) + "/" + str(health_component.max_health)
	$StaminaValueLabel.text = "%.0f/%.0f" % [stamina_component.current_stamina, stamina_component.max_stamina]
	$ExpValueLabel.text = str(exp_component.current_experience) + "/" + str(exp_component.target_experience)
	$LevelLabel.text = str(exp_component.current_level) + " lvl"
	$AttackStatLabel.text = "Damage:\n" + str(attack_controller.base_damage)
	$DefenceStatLabel.text = "Defense:\n" + str(damage_receiver.defense)	
	$ResistanceLabel.text = "Resistance:\n" + str(damage_receiver.resistance_type)
	$WeaknessLabel.text = "Weakness:\n" + str(damage_receiver.weakness_type)
	$CritStatLabel.text = "Crit:\n" + str(attack_controller.crit_chance) + "%"


func on_level_up():
	enhance_skills_button.disabled = false


func _on_enhance_skills_button_pressed() -> void:
	enhance_skills_button_pressed.emit()
	enhance_skills_button.disabled = true
