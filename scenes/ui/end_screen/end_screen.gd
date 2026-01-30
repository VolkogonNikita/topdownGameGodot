extends CanvasLayer
class_name  EndScreen

@onready var game_result_label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GameResultLabel
@onready var panel_container = $MarginContainer/PanelContainer

func _ready() -> void:
	#we do it because pivot is in left top corner by default 
	#but we need the pivot to be in the center 
	#pivot offset and size have Vector2 type, that's why we 
	#use only one string to calculate position
	#(the engine know that it needs to calculate 2 veriables) 
	panel_container.pivot_offset = panel_container.size / 2 
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	#Vector2.ONE because it's original scale (x=1, y=1)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .6)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	get_tree().paused = true

func change_to_victory():
	game_result_label.text = "Victory"
 
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level/floor.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
