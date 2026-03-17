extends Skill
class_name AxeSpell

func _init(target) -> void:
	cooldown = 3.0
	texture = preload("res://scenes/abilities/axe_ability/weapon_throwing_axe.png")
	#texture = preload("res://scenes/abilities/anvil_ability/anvil.png")
	super._init(target)

func cast_spell(target):
	pass
