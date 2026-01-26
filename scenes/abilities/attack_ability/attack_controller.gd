#added to diagram
extends Node

@export var attack_ability: PackedScene
#var attack_ability = preload("res://scenes/abilities/attack_ability/attack_ability.tscn")

@onready var timer: Timer = $Timer

var attack_range = 100
var damage = 10
var default_attack_speed

func _ready() -> void:
	Global.ability_upgrade_added.connect(on_upgrade_added)
	default_attack_speed = timer.wait_time #1.5 sec

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
	
	var attack_instance = attack_ability.instantiate() as AttackAbility
	var front_layer = get_tree().get_first_node_in_group("front_layer")
	#player.get_parent().add_child(attack_instance)
	front_layer.add_child(attack_instance)
	attack_instance.hit_box_component.damage = damage
	attack_instance.global_position = (enemies[0].global_position + player.global_position) / 2
	attack_instance.look_at(enemies[0].global_position)
	
func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id != "sword_rate":
		return
	
	var upgrade_percent = current_upgrades["sword_rate"]["quantity"] * .1
	timer.wait_time = max(0.1, default_attack_speed * (1 - upgrade_percent))
	timer.start()
	
	#print(timer.wait_time)
	
