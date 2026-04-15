extends Control

@onready var inv: Inv = preload("res://scenes/ui/final_ui/items/players_inventory.tres")
#@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@export var health_component: HealthComponent
@export var stamina_component: StaminaComponent
@export var exp_component: ExperienceManager

var is_open: bool = false

func _ready() -> void:
	#inv.update.connect(on_update_slots)
	#fupdate_slots()
	close()


func _process(delta: float) -> void:
	$HealthValueLabel.text = str(health_component.current_health) + "/" + str(health_component.max_health)
	$StaminaValueLabel.text = str(stamina_component.current_stamina) + "/" + str(stamina_component.max_stamina)
	$ExpValueLabel.text = str(exp_component.current_experience) + "/" + str(exp_component.target_experience)

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


#func on_update_slots():
	#for i in range(min(inv.slots.size(), slots.size())):
		#slots[i].update(inv.slots[i])
