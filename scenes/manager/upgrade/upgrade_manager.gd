# upgrade_manager.gd
extends Node

@export var experience_manager: ExperienceManager

var fireball_ability: FireballAbility
var heal_ability: HealAbility
var shield_ability: ShieldAbility
var thunder_ability: ThunderAbility
var sword_ability: SwordAbility

signal ability_upgraded(ability_name: String, new_level: int)


func _ready() -> void:
	experience_manager.level_up.connect(on_level_up)
	
	# Находим все способности
	call_deferred("find_abilities")


func find_abilities() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	fireball_ability = player.find_child("FireballAbility", true, false)
	heal_ability = player.find_child("HealAbility", true, false)
	shield_ability = player.find_child("ShieldAbility", true, false)
	thunder_ability = player.find_child("ThunderAbility", true, false)
	sword_ability = player.find_child("SwordAbility", true, false)


func on_level_up(new_level: int) -> void:
	upgrade_fireball()
	upgrade_heal()
	upgrade_shield()
	upgrade_thunder()
	upgrade_sword()

func upgrade_fireball() -> void:
	if fireball_ability:
		fireball_ability.damage += fireball_ability.bonus_damage_per_level
		fireball_ability.stamina_cost += fireball_ability.bonus_stamina_cost_per_level

func upgrade_heal() -> void:
	if heal_ability:
		heal_ability.heal += heal_ability.bonus_heal_per_level
		heal_ability.stamina_cost += heal_ability.bonus_stamina_per_level


func upgrade_shield() -> void:
	if shield_ability:
		shield_ability.shield_duration += shield_ability.bonus_shield_duration_per_level
		shield_ability.stamina_cost += shield_ability.bosus_stamina_cost_per_level


func upgrade_thunder() -> void:
	if thunder_ability:
		thunder_ability.damage += thunder_ability.bonus_damage_per_level
		thunder_ability.duration += thunder_ability.bonus_duration_per_level


func upgrade_sword() -> void:
	if sword_ability:
		sword_ability.charge_time += sword_ability.bonus_charge_time_per_level
		sword_ability.crit_bonus_multiplier += sword_ability.bonus_crit_bonus_multiplier_per_level
