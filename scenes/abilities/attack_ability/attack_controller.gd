extends Node

#@export var attack_ability: PackedScene

var attack_ability = preload("res://scenes/abilities/attack_ability/attack_ability.tscn")

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player: return 
	
	var attack_instance = attack_ability.instantiate()
	player.get_parent().add_child(attack_instance)
	attack_instance.global_position = player.global_position
	
