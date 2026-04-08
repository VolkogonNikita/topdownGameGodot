extends Node

@export var axe_ability_scene: PackedScene

@onready var timer: Timer = $Timer

var damage = 10
var damage_multiplier = 1
var is_on_cooldown: bool = false

func _ready():
	Global.ability_upgrade_added.connect(on_upgrade_added)
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(on_cooldown_finished)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("axe_attack"):#1
		perform_attack()


func perform_attack():
	if is_on_cooldown:
		print("Топор на кд")
		return
		
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: 
		return
	
	var front_layer = get_tree().get_first_node_in_group("front_layer") as Node2D
	if !front_layer:
		print("+")
	
	var axe_ability_instance = axe_ability_scene.instantiate() as AxeAbility
	front_layer.add_child(axe_ability_instance)
	axe_ability_instance.global_position = player.global_position
	axe_ability_instance.hit_box_component.damage = damage * damage_multiplier
	
	start_cooldown()


func start_cooldown():
	is_on_cooldown = true
	timer.start()
	update_ui_cooldown(true)


func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		damage_multiplier += (current_upgrades["axe_damage"]["quantity"] * .12)


func on_cooldown_finished():
	is_on_cooldown = false
	print("Топор готов")
	update_ui_cooldown(false)


func update_ui_cooldown(on_cooldown: bool):
	pass
