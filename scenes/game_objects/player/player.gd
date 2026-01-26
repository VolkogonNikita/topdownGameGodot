#added to diagram
extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var grace_period = $GracePeriod
@onready var progress_bar = $ProgressBar
@onready var ability_manager = $AbilityManager
@onready var animated_sprite_2d = $AnimatedSprite2D

var SPEED = 200
var acceleration = .15
var enemies_colliding = 0 #how many enemies attacks player at the moment

func _ready():
	health_component.died.connect(on_died)
	health_component.health_changed.connect(on_health_changed)
	Global.ability_upgrade_added.connect(on_ability_upgrade_added)
	health_update()

func _process(_delta: float) -> void:
	var direction = movement_vector().normalized()
	var target_velocity = SPEED * direction
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()
	
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("run")
	else: animated_sprite_2d.play("idle")
	
	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

func movement_vector():
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	return Vector2(movement_x, movement_y)
	
func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_down","move_left","move_right","move_up")


func check_if_damaged():
	if enemies_colliding == 0 || !grace_period.is_stopped():
		return
	health_component.take_damage(1)
	grace_period.start()
	
	print(health_component.current_health)


func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	enemies_colliding += 1
	check_if_damaged()


func _on_player_hurt_box_area_exited(area: Area2D) -> void:
	enemies_colliding -= 1


func on_died():
	queue_free()


func health_update():
	progress_bar.value = health_component.get_health_value()


func on_health_changed():
	health_update()


func _on_grace_period_timeout() -> void:
	check_if_damaged()


func on_ability_upgrade_added(upgrade:AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade is NewAbility:
		return 
	var new_ability = upgrade as NewAbility
	ability_manager.add_child(new_ability.new_ability_scene.instantiate())
