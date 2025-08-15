extends Node

#@export var attack_ability: PackedScene
var attack_ability = preload("res://scenes/abilities/attack_ability/attack_ability.tscn")

var attack_range = 100

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player: return 
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	enemies = enemies.filter(func(enemy:Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(attack_range, 2)
	)
	
	if !enemies.size():
		return 
	
	enemies.sort_custom(func(a:Node2D, b:Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	
	var attack_instance = attack_ability.instantiate()
	player.get_parent().add_child(attack_instance)
	attack_instance.global_position = (enemies[0].global_position + player.global_position) / 2
	attack_instance.look_at(enemies[0].global_position)
	
