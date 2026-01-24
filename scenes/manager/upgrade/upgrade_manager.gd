#added to diagram
extends Node

@export var experience_manager: ExperienceManager
@export var upgrade_pool: Array[AbilityUpgrade]
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}


func _ready() -> void:
	experience_manager.level_up.connect(on_level_up)

	
func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"upgrade": upgrade,
			"quantity": 1
		}		
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	Global.ability_upgrade_added.emit(upgrade, current_upgrades)


func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade]
	var pool_copy = upgrade_pool.duplicate()
	for i in 2:
		var chosen_upgrade = pool_copy.pick_random() as AbilityUpgrade
		chosen_upgrades.append(chosen_upgrade)
		pool_copy = pool_copy.filter(func(upgrade): return upgrade.id != chosen_upgrade.id)
	
	return chosen_upgrades

func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)


func on_level_up(current_level):
	var upgrade_sceen_instance = upgrade_screen_scene.instantiate() as UpgradeScreen
	add_child(upgrade_sceen_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_sceen_instance.set_ability_upgrades(chosen_upgrades) #as Array[AbilityUpgrade]
	upgrade_sceen_instance.update_selected.connect(on_upgrade_selected)
