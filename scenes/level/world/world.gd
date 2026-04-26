extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time: Label = $CanvasLayer/time
@onready var rain: Rain = $CanvasLayer/Rain

var player = null
var pause_menu_scene = preload("res://scenes/ui/pause_menu/pause_menu.tscn")
var puddle_scene = preload("res://scenes/level/world/puddle.tscn")
var slug_scene = preload("res://scenes/game_objects/enemies/slug/slug.tscn")

@export var puddle_lifetime: float = 10   
@export var spawn_delay: float = 0.03     
@export var puddle_max_count: int = 1000   

var go_rain: bool
var puddle_count = 0
var puddle_timer: float = 0.0
var slug_count = 0

func _ready() -> void:
	#Global.dungeon_quest_ended.connect(on_dungeon_quest_ended)
	rain.is_raining.connect(on_is_raining)
	rain.isnt_raining.connect(on_isnt_raining)
	MusicPlayer.play()


func _process(delta: float) -> void:
	on_dungeon_quest_ended()
	animation_player.play("day-night")
	#spawn_puddle()
	#is_raining()
	if player: 
		if Input.is_action_just_pressed("action"):
			await get_tree().create_timer(0.5).timeout
			MetaProgression.save_state()      # 1. Сохраняем текущее состояние
			MetaProgression.request_load()
			get_tree().change_scene_to_file("res://scenes/level/floor.tscn")


func spawn_puddle():
	var puddle = puddle_scene.instantiate()
	puddle.position = Vector2(randf_range(-1000, 2000), randf_range(-1000,2000))
	add_child(puddle)
	puddle_count += 1
	var timer = get_tree().create_timer(puddle_lifetime)
	timer.timeout.connect(func(): 
		if is_instance_valid(puddle): 
			puddle.queue_free() 
			puddle_count -= 1 )


func spawn_slug():
	var slug = slug_scene.instantiate()
	slug.position = Vector2(randf_range(-256, 500), randf_range(0,512))
	if slug_count < 5:
		add_child(slug)
		slug_count += 1
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body 


func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())


func morning():
	$CanvasLayer/time.text = "time: morning"
	$Environment1/PointLight2D.energy = 0.0
	$Environment1/PointLight2D2.energy = 0.0
	$Environment1/PointLight2D3.energy = 0.0
	$Environment1/PointLight2D4.energy = 0.0
	$Environment1/PointLight2D5.energy = 0.0


func day():
	$CanvasLayer/time.text = "time: day"


func evening():
	$CanvasLayer/time.text = "time: evening"
	$Environment1/PointLight2D.energy = 1.0
	$Environment1/PointLight2D2.energy = 1.0
	$Environment1/PointLight2D3.energy = 1.0
	$Environment1/PointLight2D4.energy = 1.0
	$Environment1/PointLight2D5.energy = 1.0


func night():
	$CanvasLayer/time.text = "time: night"


func is_raining():
	if go_rain:
		spawn_puddle()
		spawn_slug()
	else: 
		slug_count = 0
		return

func on_is_raining():
	go_rain = true


func on_isnt_raining():
	go_rain = false


func on_dungeon_quest_ended():
	if Global.was_in_dungeon:
		$Environment1/Door/Area2D.monitorable = false
		$Environment1/Door/Area2D.monitoring = false
