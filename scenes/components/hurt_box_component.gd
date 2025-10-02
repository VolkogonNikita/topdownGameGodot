extends Area2D
class_name HurtBoxComponent

@export var heath_component: HeathComponent

func _on_area_entered(area: Area2D) -> void:
	if not area is HitBoxComponent:
		return
	
	if heath_component == null:
		return
		
	var hit_box_component = area as HitBoxComponent
	heath_component.take_damage(hit_box_component.damage)
