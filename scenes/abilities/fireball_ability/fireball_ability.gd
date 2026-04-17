# fireball_spell.gd
extends Node2D

@export var damage: int = 15
@export var speed: float = 300.0
@export var max_distance: float = 500.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var direction: Vector2 = Vector2.ZERO
var start_position: Vector2
var is_active: bool = true


func _ready() -> void:
	start_position = global_position
	
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	if animated_sprite_2d:
		animated_sprite_2d.play("default")
	
	# Направление к курсору
	direction = (get_global_mouse_position() - global_position).normalized()


func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta
		rotation = direction.angle()
		
		if global_position.distance_to(start_position) > max_distance:
			queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	
	# Наносим урон только врагам
	if body.is_in_group("enemy"):
		var health_component = body.find_child("HealthComponent", true, false)
		if health_component and health_component.has_method("take_damage"):
			health_component.take_damage(damage)
		queue_free()
