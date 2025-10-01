extends Node2D

var bottle_experience = 5

func _on_area_2d_area_entered(_area: Area2D) -> void:
	Global.experience_bottle_collected.emit(bottle_experience)
	queue_free()
