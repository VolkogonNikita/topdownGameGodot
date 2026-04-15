extends Skill
class_name HealSpell

func _init(target) -> void:
	cooldown = 3.0
	#texture = preload("res://scenes/abilities/axe_ability/weapon_throwing_axe.png")
	texture = preload("res://assets/skill_icons_by_quintino_pixels/24x24/skill_icons10.png")
	super._init(target)

func cast_spell(target):
	pass
