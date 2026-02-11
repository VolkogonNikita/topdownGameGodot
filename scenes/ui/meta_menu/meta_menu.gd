extends CanvasLayer

@export var upgrades: Array[MetaUpgrade] = []

#@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var grid_container: GridContainer = %GridContainer

var meta_upgrade_card_scene = preload("res://scenes/ui/meta_upgrade_card/meta_upgrade_card.tscn")

func _ready():
	for upgrade in upgrades:
		var meta_upgrade_card_instance = meta_upgrade_card_scene.instantiate()
		grid_container.add_child(meta_upgrade_card_instance)
		meta_upgrade_card_instance.set_meta_upgrade(upgrade)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu/main_menu.tscn")
