#added to diagram
extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var movement_component = $MovementComponent

@export var death_scene: PackedScene
@export var sprite: CompressedTexture2D


func _ready() -> void:
	health_component.died.connect(on_died)


func _process(_delta: float) -> void:
	var direction = movement_component.get_direction()
	movement_component.move_to_player(self)
	
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("run")
	else: animated_sprite_2d.play("idle")
	
	var face_sign = sign(direction.x)
	
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign


func on_died():
	var back_layer = get_tree().get_first_node_in_group("back_layer")
	var death_instance = death_scene.instantiate() as DeathComponent
	back_layer.add_child(death_instance)
	death_instance.gpu_particles_2d.texture = sprite
	#this is for right sprite position. need to append parent for GPUParticle2D node2d and give name sprite_offset
	#death_instance.sprite_offset.position.y = animated_sprite_2d.offset.y
	death_instance.global_position = global_position
	queue_free()
