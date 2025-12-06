extends CharacterBody2D

@onready var button = preload("res://node.gd")
var current_button_instance = null
var SPEED = 300
var label_name = preload("res://label_name.tscn")
var label_name_instance = null

func _ready():
	var label_scene = preload("res://label_name.tscn")
	label_name_instance = label_scene.instantiate()
	label_name_instance.get_node("Label").text = "Player"
	add_child(label_name_instance)
	
	label_name_instance.position = $Marker2D.position

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED

func player():
	pass
