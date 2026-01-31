extends Node2D
class_name DeathComponent

@onready var gpu_particles_2d = $GPUParticles2D

func _ready():
	$HitSoundComponent.play()
	$AudioStreamPlayer2D.play()
