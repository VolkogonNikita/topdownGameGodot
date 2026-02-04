#added to diagram
extends PanelContainer
class_name MetaUpdateCard

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var animation_player = $AnimationPlayer
@onready var purchase_button: Button = $MarginContainer/VBoxContainer/VBoxContainer2/PurchaseButton
@onready var progress_label: Label = $MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/ProgressLabel
@onready var progress_bar: ProgressBar = %ProgressBar

var upgrade: MetaUpgrade


func set_meta_upgrade(upgrade: MetaUpgrade):
	self.upgrade = upgrade
	name_label.text = upgrade.name
	description_label.text = upgrade.description
	update_progress()


func update_progress():
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var percent = currency / upgrade.cost
	percent = min(percent, 1)
	progress_bar.value = percent
	purchase_button.disabled = percent < 1 
	progress_label.text = str(currency) + "/" + str(upgrade.cost)


func _on_purchase_button_pressed() -> void:
	if upgrade == null:
		return
	MetaProgression.add_meta_upgrade(upgrade)
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.cost
	MetaProgression.save_file()
	#обновить инфу для всех карт из группы
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")
