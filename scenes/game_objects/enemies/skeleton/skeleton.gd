#added to diagram
extends CharacterBody2D

var SKELETON_SPEED = 50
var SKELETON_STATE = "idle"

@onready var health_component = $HealthComponent
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var death_scene: PackedScene
@export var sprite: CompressedTexture2D


func _ready() -> void:
	health_component.died.connect(on_died)

func _process(_delta: float) -> void:
	var direction = get_direction_to_player()
	velocity = SKELETON_SPEED * direction#*delta
	move_and_slide()
	
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("skeleton_run")
	else: animated_sprite_2d.play("skeleton_idle")
	
	var face_sign = sign(direction.x)
	
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign
		

func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		SKELETON_STATE = "run"
		return (player.global_position - self.global_position).normalized()
	return Vector2.ZERO

func _physics_process(delta: float) -> void:
	if SKELETON_STATE == "run":
		$AnimatedSprite2D.play("skeleton_run")
	if SKELETON_STATE == "idle":
		$AnimatedSprite2D.play("skeleton_idle")

func on_died():
	var back_layer = get_tree().get_first_node_in_group("back_layer")
	var death_instance = death_scene.instantiate() as DeathComponent
	back_layer.add_child(death_instance)
	death_instance.gpu_particles_2d.texture = sprite
	death_instance.global_position = global_position
	queue_free()
