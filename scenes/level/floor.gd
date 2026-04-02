extends Node

@export var end_screen_scene: PackedScene
@export var arena_time_manager: ArenaTimeManager

@onready var player = $Back/player

var pause_menu_scene = preload("res://scenes/ui/pause_menu/pause_menu.tscn")

func _ready():
	MusicPlayer.play()
	player.health_component.died.connect(on_died)
	#player = null


func _process(delta: float) -> void:
	if player:
		if Input.is_action_just_released("action"):
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://scenes/level/world/world.tscn")

func on_died():
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	add_child(end_screen_instance)
	end_screen_instance.update_gold_to_add(arena_time_manager.gold_to_add())
	end_screen_instance.play_jingle()

#встроенная функция для обработки ввода клавиши
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())	



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("exit")
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
