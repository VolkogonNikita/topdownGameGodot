# fireball_spell.gd
extends Node2D
class_name FireballAbility

@export var damage: int = 15
@export var speed: float = 300.0
@export var max_distance: float = 500.0
@export var cooldown: float = 1.0
@export var spawn_offset: float = 24.0
@export var stamina_component: StaminaComponent
@export var stamina_cost: int = 10
@export var bonus_damage_per_level = 10
@export var bonus_stamina_cost_per_level = 10

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var direction: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO

var has_launched: bool = false
var can_cast: bool = true
var player: Node2D = null

signal run_cooldown

func _ready() -> void:
	# при запуске карты снаряд скрыт и неактивен
	hide()
	set_process(true)
	set_physics_process(true)

	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	if animated_sprite_2d:
		animated_sprite_2d.play("default")


func _process(delta: float) -> void:
	# если сменили сцену — ищем нового player
	if player == null or !is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	if Input.is_action_just_pressed("fireball_attack"):
		if can_cast and not has_launched and player != null:
			launch_fireball()


func launch_fireball() -> void:
	if !stamina_component.use_stamina(stamina_cost):
		return
	
	run_cooldown.emit()
	
	has_launched = true
	can_cast = false
	show()

	# направление от игрока к мышке
	direction = (get_global_mouse_position() - player.global_position).normalized()

	# позиция появления
	global_position = player.global_position + direction * spawn_offset
	start_position = global_position

	# поворот в сторону полёта
	rotation = direction.angle()

	if animated_sprite_2d:
		animated_sprite_2d.play("default")

	start_cooldown()


func _physics_process(delta: float) -> void:
	if not has_launched:
		return

	# движение
	global_position += direction * speed * delta
	rotation = direction.angle()

	# уничтожение после прохождения max_distance
	if global_position.distance_to(start_position) >= max_distance:
		reset_fireball()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if not has_launched:
		return

	if body.is_in_group("enemy"):
		var health_component = body.find_child("HealthComponent", true, false)

		if health_component and health_component.has_method("take_damage"):
			health_component.take_damage(damage)

		reset_fireball()


func reset_fireball() -> void:
	has_launched = false
	direction = Vector2.ZERO
	hide()


func start_cooldown() -> void:
	await get_tree().create_timer(cooldown).timeout
	can_cast = true
