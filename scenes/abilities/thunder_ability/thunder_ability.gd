# lightning_strike.gd
extends Node2D

@export var damage: int = 8
@export var tick_rate: float = 0.5          # интервал урона
@export var duration: float = 3.0           # сколько существует зона
@export var cooldown: float = 2.0          # откат способности

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var can_cast: bool = true
var is_active: bool = false


func _ready() -> void:
	hide()

	#if animated_sprite_2d:
		#animated_sprite_2d.play("default")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("thunder"):
		print("thunder")
		if can_cast and not is_active:
			cast_lightning()


func cast_lightning() -> void:
	can_cast = false
	is_active = true

	# появляется в точке курсора
	global_position = get_global_mouse_position()

	show()

	if animated_sprite_2d:
		animated_sprite_2d.play("default")

	damage_loop()
	start_duration()
	start_cooldown()


func damage_loop() -> void:
	while is_active:
		var bodies = hitbox.get_overlapping_bodies()

		for body in bodies:
			if body.is_in_group("enemy"):
				var health_component = body.find_child("HealthComponent", true, false)

				if health_component and health_component.has_method("take_damage"):
					health_component.take_damage(damage)

		await get_tree().create_timer(tick_rate).timeout


func start_duration() -> void:
	await get_tree().create_timer(duration).timeout
	deactivate()


func deactivate() -> void:
	is_active = false
	hide()


func start_cooldown() -> void:
	await get_tree().create_timer(cooldown).timeout
	can_cast = true
