#added to diagram
extends PanelContainer
class_name AbilityUpdateCard

signal card_selected

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel

func set_ability_upgrade(upgrade: AbilityUpgrade):
	name_label.text = upgrade.name
	description_label.text = upgrade.description

#нажатие на элемент интерфейса
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		card_selected.emit()
