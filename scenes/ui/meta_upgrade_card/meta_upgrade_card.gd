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
