# DamageReceiver.gd
extends Node
class_name DamageReceiver

@export var defense: float = 200.0
@export var crit_resistance: float = 0.0  # Уменьшает шанс крита противника
@export_enum("None", "Physical", "Fire", "Electric") var resistance_type: String = "None"
@export_enum("None", "Physical", "Fire", "Electric") var weakness_type: String = "None"

@export var health_component: HealthComponent
@export var floating_number_scene: PackedScene

signal damage_received(final_damage: float, is_crit: bool, damage_type: String)

func take_damage(base_damage: float, damage_type: String, attacker_crit_chance: float = 0.0):
	# Учитываем сопротивление к критам
	var effective_crit_chance = max(0, attacker_crit_chance - crit_resistance)
	
	# Рассчитываем урон
	var result = DamageCalculator.calculate_final_damage(
		base_damage,
		damage_type,
		resistance_type,
		weakness_type,
		defense,
		effective_crit_chance
	)
	
	var final_damage = result.damage
	var is_crit = result.is_crit
	
	# Наносим урон здоровью
	if health_component:
		health_component.take_damage(final_damage)
	
	# Спавним летающий урон (опционально)
	spawn_floating_number(final_damage, is_crit)
	
	# Сигнал для анимаций/эффектов
	damage_received.emit(final_damage, is_crit, damage_type)
	
	# Отладка
	print("Получен урон: %.1f (базовый: %.1f) | Крит: %s | Тип: %s" % [final_damage, base_damage, is_crit, damage_type])
	print("  - Защита снизила на: %.1f" % result.defense_reduced)
	
	return final_damage

func spawn_floating_number(damage: float, is_crit: bool):
	if not floating_number_scene:
		return
	
	var number_instance = floating_number_scene.instantiate()
	get_tree().current_scene.add_child(number_instance)
	number_instance.global_position = get_parent().global_position - Vector2(0, 50)
	
	var label = number_instance.find_child("Label")
	if label:
		label.text = "%.0f" % damage
	
	var anim_player = number_instance.find_child("AnimationPlayer")
	if anim_player:
		if is_crit:
			anim_player.play("crit")
		else:
			anim_player.play("normal")
