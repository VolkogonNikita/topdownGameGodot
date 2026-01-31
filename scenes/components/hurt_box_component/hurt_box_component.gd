#added to diagram
extends Area2D
class_name HurtBoxComponent

@export var heath_component: HeathComponent
@export var hit_sound_component: AudioStreamPlayer2D

func _on_area_entered(area: Area2D) -> void:
	if not area is HitBoxComponent:
		return
	
	if heath_component == null:
		return
		
	var hit_box_component = area as HitBoxComponent
	heath_component.take_damage(hit_box_component.damage)
	hit_sound_component.play()
