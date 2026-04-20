#added to diagram
class_name Player
extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var grace_period = $GracePeriod
@onready var ability_manager = $AbilityManager
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var movement_component = $MovementComponent
@onready var stamina_component = $StaminaComponent 
@onready var shield_ability: Node2D = $AbilityManager/ShieldAbility

@export var health_regen: int = 1
@export var inventory: Inv
@export var mini_profile: MiniProfile

var enemies_colliding = 0
var enemy_damage: int = 0
var base_speed = 0

func _ready():
	base_speed = movement_component.max_speed
	health_component.died.connect(on_died)
	health_component.get_damage.connect(on_health_decreased)
	shield_ability.shield_is_active.connect(on_shield_is_active)
	shield_ability.shield_is_inactive.connect(on_shield_is_inactive)
	Global.ability_upgrade_added.connect(on_ability_upgrade_added)
	
	# Подключаем стамину к профилю
	if stamina_component and mini_profile:
		stamina_component.stamina_changed.connect(mini_profile.update_stamina_bar)
		stamina_component.stamina_depleted.connect(_on_stamina_depleted)

func _physics_process(_delta: float) -> void:
	var direction = movement_vector().normalized()
	
	# Управляем бегом (зажат Shift или другая кнопка)
	var is_running = Input.is_action_pressed("run") and direction.length() > 0
	movement_component.set_running(is_running)
	
	# Рассчитываем скорость
	velocity = movement_component.acceleration_to_direction(direction)
	move_and_slide()
	
	# Анимации
	if direction.length() > 0:
		if is_running and stamina_component and stamina_component.has_stamina():
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	# Поворот спрайта
	if direction.x != 0:
		animated_sprite_2d.scale.x = sign(direction.x)

func movement_vector():
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(movement_x, movement_y)


func collect(item):
	inventory.insert(item)


func check_if_damaged():
	if enemies_colliding == 0 || !grace_period.is_stopped():
		return
	health_component.take_damage(enemy_damage)
	grace_period.start()
	print("grace period = ", grace_period.wait_time)


func on_health_decreased():
	Global.player_damaged.emit()
	$AudioStreamPlayer2D.play()
#	health_update()


func on_ability_upgrade_added(upgrade:AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade is NewAbility:	 
		var new_ability = upgrade as NewAbility
		ability_manager.add_child(new_ability.new_ability_scene.instantiate())
	
	elif upgrade.id == "move_speed":
		movement_component.max_speed = base_speed + (base_speed * current_upgrades["move_speed"]["quantity"] * .1)

func on_died():
	queue_free()

func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	enemy_damage = area.enemy_damage()
	enemies_colliding += 1
	check_if_damaged()

func _on_player_hurt_box_area_exited(area: Area2D) -> void:
	enemies_colliding -= 1

func _on_grace_period_timeout() -> void:
	check_if_damaged()

func _on_health_regen_timer_timeout() -> void:
	#var health_regen_bonus = MetaProgression.get_upgrade_quantity("health_regeneration")
	health_component.take_heal(health_regen + 1)

func _on_stamina_depleted():
	# Можно добавить визуальный эффект или звук
	print("Stamina depleted!")


func on_shield_is_active():
	grace_period.wait_time = 5


func on_shield_is_inactive():
	grace_period.wait_time = 1
