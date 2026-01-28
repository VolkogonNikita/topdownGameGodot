#added to diagram
extends CanvasLayer
class_name UpgradeScreen

signal update_selected(upgrade: AbilityUpgrade)

@export var upgrade_card_scene: PackedScene
@onready var card_container: HBoxContainer = $MarginContainer/CardContainer

func _ready() -> void:
	get_tree().paused = true

func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):
	var delay = 0
	for upgrade in upgrades:
		var upgrade_card_instance = upgrade_card_scene.instantiate() as AbilityUpdateCard
		card_container.add_child(upgrade_card_instance)
		upgrade_card_instance.set_ability_upgrade(upgrade)
		upgrade_card_instance.play_in(delay)
		upgrade_card_instance.card_selected.connect(on_upgrade_selected.bind(upgrade))
		delay += 0.1 

func on_upgrade_selected(upgrade: AbilityUpgrade):
	update_selected.emit(upgrade)
	get_tree().paused = false
	queue_free()
