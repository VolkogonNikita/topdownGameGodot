extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time: Label = $CanvasLayer/time

var player = null
var pause_menu_scene = preload("res://scenes/ui/pause_menu/pause_menu.tscn")

func _ready() -> void:
	MusicPlayer.play()


func _process(delta: float) -> void:
	animation_player.play("day-night")
	if player: 
		if Input.is_action_just_pressed("action"):
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://scenes/level/floor.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body 


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())	
