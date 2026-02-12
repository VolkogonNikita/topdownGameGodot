extends Node

@export var axe_ability_scene: PackedScene

var damage = 10
var damage_multiplier = 1

func _ready():
	Global.ability_upgrade_added.connect(on_upgrade_added)


func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		damage_multiplier += (current_upgrades["axe_damage"]["quantity"] * .12)


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: 
		return
	
	var front_layer = get_tree().get_first_node_in_group("front_layer") as Node2D
	
	var axe_ability_instance = axe_ability_scene.instantiate() as AxeAbility
	front_layer.add_child(axe_ability_instance)
	axe_ability_instance.global_position = player.global_position
	axe_ability_instance.hit_box_component.damage = damage * damage_multiplier
