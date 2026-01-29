#added to diagram
extends PanelContainer
class_name AbilityUpdateCard

signal card_selected

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var animation_player = $AnimationPlayer

var disabled = false

func set_ability_upgrade(upgrade: AbilityUpgrade):
	name_label.text = upgrade.name
	description_label.text = upgrade.description


func play_in(delay):
	modulate.a = 0
	await get_tree().create_timer(delay).timeout
	animation_player.play("in")


#нажатие на элемент интерфейса
func _on_gui_input(event: InputEvent) -> void:
	if disabled: return
	if event.is_action_pressed("left_click"):
		disabled = true
		for card in get_tree().get_nodes_in_group("upgrade_card"):
			if card == self:
				animation_player.play("selected")
			else: card.animation_player.play("discard")
		await animation_player.animation_finished
		card_selected.emit()


#func _on_panel_container_gui_input(event: InputEvent) -> void:
	#if disabled: return
	#if event.is_action_pressed("left_click"):
		#disabled = true
		#for card in get_tree().get_nodes_in_group("upgrade_card"):
			#if card == self:
				#animation_player.play("selected")
			#else: card.animation_player.play("discard")
		#await animation_player.animation_finished
		#card_selected.emit()


func _on_mouse_entered() -> void:
	if disabled: return
	scale = Vector2(1.1, 1.1)


func _on_mouse_exited() -> void:
	if disabled: return
	scale = Vector2(1.0, 1.0)


#func _on_panel_container_mouse_entered() -> void:
	#if disabled: return
	#scale = Vector2(1.1, 1.1)


#func _on_panel_container_mouse_exited() -> void:
	#if disabled: return
	#scale = Vector2(1.0, 1.0)
