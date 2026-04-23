# upgrade_manager.gd
extends Node

@export var inv_ui: InvUI

var fireball_ability: FireballAbility
var heal_ability: HealAbility
var shield_ability: ShieldAbility
var thunder_ability: ThunderAbility
var sword_ability: SwordAbility
var damage_receiver: DamageReceiver
var attack_controller: AttackController


func _ready() -> void:
	inv_ui.enhance_skills_button_pressed.connect(on_enhance_skills_button_pressed)
	call_deferred("find_abilities_and_stats")


func find_abilities_and_stats() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	fireball_ability = player.find_child("FireballAbility", true, false)
	heal_ability = player.find_child("HealAbility", true, false)
	shield_ability = player.find_child("ShieldAbility", true, false)
	thunder_ability = player.find_child("ThunderAbility", true, false)
	sword_ability = player.find_child("SwordAbility", true, false)
	
	damage_receiver = player.find_child("DamageReceiver", true, false)
	attack_controller = player.find_child("AttackController", true, false)


func on_enhance_skills_button_pressed() -> void:
	upgrade_fireball()
	upgrade_heal()
	upgrade_shield()
	upgrade_thunder()
	upgrade_sword()
	upgrade_stats()


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


func upgrade_stats() -> void:
	if damage_receiver:
		damage_receiver.defense += 50
		damage_receiver.crit_resistance += 1
	
	if attack_controller:
		attack_controller.base_damage += 10
		attack_controller.crit_chance += 5
	pass
