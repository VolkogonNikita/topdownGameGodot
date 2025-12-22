extends CanvasLayer
class_name  EndScreen

@onready var game_result_label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GameResultLabel


func _ready() -> void:
	get_tree().paused = true

func change_to_victory():
	game_result_label.text = "Victory"
 
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level/floor.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
