# DamageCalculator.gd
extends Node
class_name DamageCalculator

# Базовая формула защиты (из вашего mini_boss)
static func calculate_defense_multiplier(atk: float, defense: float) -> float:
	if atk == 0 and defense == 0:
		return 0.0
	return atk / (atk + defense)

# Критический удар
static func calculate_crit_multiplier(crit_chance: float) -> Dictionary:
	var rng = randf()
	if rng < crit_chance:
		return {"multiplier": 2.0, "is_crit": true}
	return {"multiplier": 1.0, "is_crit": false}

# Случайная вариация урона (±10%)
static func calculate_randomness() -> float:
	return randf_range(0.9, 1.1)

# Элементальное сопротивление
static func calculate_elemental_resistance(damage_type: String, resistance_type: String) -> float:
	if damage_type == resistance_type:
		return 0.9  # 10% сопротивления
	return 1.0

# Элементальная уязвимость
static func calculate_elemental_weakness(damage_type: String, weakness_type: String) -> float:
	if damage_type == weakness_type:
		return 1.75  # +75% урона
	return 1.0

# Главная функция — собирает всё вместе
static func calculate_final_damage(
	base_damage: float,
	attack_type: String,
	target_resistance: String,
	target_weakness: String,
	target_defense: float,
	crit_chance: float
) -> Dictionary:
	
	# Защита
	var defense_mult = calculate_defense_multiplier(base_damage, target_defense)
	
	# Крит
	var crit_result = calculate_crit_multiplier(crit_chance)
	
	# Элементы
	var resist_mult = calculate_elemental_resistance(attack_type, target_resistance)
	var weakness_mult = calculate_elemental_weakness(attack_type, target_weakness)
	
	# Случайность
	var random_mult = calculate_randomness()
	
	# Итоговый урон
	var final_damage = base_damage * defense_mult * crit_result.multiplier * resist_mult * weakness_mult * random_mult
	
	return {
		"damage": final_damage,
		"is_crit": crit_result.is_crit,
		"defense_reduced": base_damage - (base_damage * defense_mult),
		"elemental_bonus": (resist_mult * weakness_mult - 1.0) * 100  # в процентах
	}
