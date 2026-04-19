#added to diagram
extends Node
class_name ExperienceManager

signal experience_update(current_experience:float, target_experience:float)
#signal level_up(current_level)
signal level_up

var current_experience = 0
var target_experience = 1 #5
var target_after_lvlup = 5 #5
var current_level = 1

func _ready() -> void:
	Global.experience_bottle_collected.connect(on_experience_bottle_collected)

func on_experience_bottle_collected(experience):
	current_experience = min(current_experience + experience, target_experience)
	experience_update.emit(current_experience, target_experience)
	
	if current_experience == target_experience:
		current_level += 1
		current_experience = 0
		target_experience += target_after_lvlup
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_node("HealthComponent"):
			var player_health_component = player.get_node("HealthComponent")
			player_health_component.max_health *= 1.1
			print("max_health", player_health_component.max_health)
			
		if player and player.has_node("StaminaComponent"):
			var player_stamina_component = player.get_node("StaminaComponent")
			player_stamina_component.max_stamina *= 1.1
			print("max_stamina", player_stamina_component.max_stamina)
			
		experience_update.emit(current_experience, target_experience)
		#level_up.emit(current_level)
		level_up.emit()
