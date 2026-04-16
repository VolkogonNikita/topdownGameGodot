extends Skill
class_name SwordSpell

func _init(target) -> void:
	cooldown = 6.0
	texture = preload("res://assets/skill_icons_by_quintino_pixels/96x96/skill_icons17.png")
	#texture = preload("res://scenes/abilities/anvil_ability/anvil.png")
	super._init(target)

func cast_spell(target):
	pass
