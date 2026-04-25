extends SubViewport

@onready var camera_2d: Camera2D = $Camera2D
@onready var player: Player = $"../../../Player"
@onready var sprite_2d: Sprite2D = $Sprite2D
#@onready var player: Player = $"../../../back/Player"

func _physics_process(delta: float) -> void:
	camera_2d.global_position = player.global_position
	sprite_2d.global_position = player.global_position
