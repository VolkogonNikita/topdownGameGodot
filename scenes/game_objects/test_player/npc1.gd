# animal.gd
extends CharacterBody2D

enum State {
	IDLE,
	WALKING,
	FLEEING
}

var test_bool = true

@export var walk_speed: float = 50.0
@export var idle_time_min: float = 2.0
@export var idle_time_max: float = 5.0
@export var walk_time_min: float = 1.0
@export var walk_time_max: float = 4.0
@export var change_direction_chance: float = 0.3
@export var flee_speed_multiplier: float = 1.5
@export var flee_duration: float = 2.0
#@export var control: HTTP

# Границы движения
@export var use_boundaries: bool = true
@export var boundary_min: Vector2 = Vector2(576, 32)  # Левый верхний угол
@export var boundary_max: Vector2 = Vector2(736, 160)    # Правый нижний угол
@export var boundary_margin: float = 50.0  # За сколько до границы начинать поворот

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_timer: Timer = $IdleTimer
@onready var walk_timer: Timer = $WalkTimer
@onready var direction_timer: Timer = $DirectionTimer
@onready var label: Label = $Label

var current_state: State = State.IDLE
var walk_direction: Vector2 = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var start_position: Vector2
var flee_timer: float = 0.0
var original_speed: float


func _ready() -> void:
	rng.randomize()
	start_position = global_position
	original_speed = walk_speed
	
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	
	walk_timer.one_shot = true
	walk_timer.timeout.connect(_on_walk_timer_timeout)
	
	direction_timer.one_shot = true
	direction_timer.timeout.connect(_on_direction_timer_timeout)
	
	enter_idle_state()


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
		
		State.WALKING:
			update_walk_direction_with_boundaries()
			velocity = walk_direction * walk_speed
			animated_sprite.play("walk")
			
			if walk_direction.x != 0:
				animated_sprite.scale.x = sign(walk_direction.x)
		
		State.FLEEING:
			flee_timer -= delta
			if flee_timer <= 0:
				walk_speed = original_speed
				enter_idle_state()
			else:
				update_flee_direction_with_boundaries()
				velocity = walk_direction * walk_speed
				animated_sprite.play("walk")
				
				if walk_direction.x != 0:
					animated_sprite.scale.x = sign(walk_direction.x)
	
	move_and_slide()


func update_walk_direction_with_boundaries() -> void:
	if not use_boundaries:
		return
	
	# Проверяем, не выходим ли за границы
	var next_position = global_position + walk_direction * walk_speed * get_physics_process_delta_time()
	
	if next_position.x < boundary_min.x + boundary_margin:
		walk_direction.x = abs(walk_direction.x)  # Поворачиваем вправо
	elif next_position.x > boundary_max.x - boundary_margin:
		walk_direction.x = -abs(walk_direction.x)  # Поворачиваем влево
	
	if next_position.y < boundary_min.y + boundary_margin:
		walk_direction.y = abs(walk_direction.y)  # Поворачиваем вниз
	elif next_position.y > boundary_max.y - boundary_margin:
		walk_direction.y = -abs(walk_direction.y)  # Поворачиваем вверх
	
	walk_direction = walk_direction.normalized()


func update_flee_direction_with_boundaries() -> void:
	if not use_boundaries:
		return
	
	var next_position = global_position + walk_direction * walk_speed * get_physics_process_delta_time()
	
	# При убегании тоже не выходим за границы
	if next_position.x < boundary_min.x + boundary_margin:
		walk_direction.x = abs(walk_direction.x)
	elif next_position.x > boundary_max.x - boundary_margin:
		walk_direction.x = -abs(walk_direction.x)
	
	if next_position.y < boundary_min.y + boundary_margin:
		walk_direction.y = abs(walk_direction.y)
	elif next_position.y > boundary_max.y - boundary_margin:
		walk_direction.y = -abs(walk_direction.y)
	
	walk_direction = walk_direction.normalized()


func enter_idle_state() -> void:
	current_state = State.IDLE
	if label:
		label.text = ""
	idle_timer.start(rng.randf_range(idle_time_min, idle_time_max))


func enter_walk_state() -> void:
	current_state = State.WALKING
	choose_random_direction()
	walk_timer.start(rng.randf_range(walk_time_min, walk_time_max))
	direction_timer.start(rng.randf_range(0.5, 1.5))


func choose_random_direction() -> void:
	var angle = rng.randf_range(0, TAU)
	walk_direction = Vector2.RIGHT.rotated(angle)
	
	# Если включены границы, предпочитаем направление к центру зоны
	if use_boundaries:
		adjust_direction_to_boundaries()


func adjust_direction_to_boundaries() -> void:
	# Если NPC слишком близко к границе, разворачиваем его к центру
	var center = (boundary_min + boundary_max) / 2
	var to_center = (center - global_position).normalized()
	
	var distance_to_left = global_position.x - boundary_min.x
	var distance_to_right = boundary_max.x - global_position.x
	var distance_to_top = global_position.y - boundary_min.y
	var distance_to_bottom = boundary_max.y - global_position.y
	
	var min_distance = min(distance_to_left, distance_to_right, distance_to_top, distance_to_bottom)
	
	if min_distance < boundary_margin:
		# Близко к границе — идём к центру
		walk_direction = walk_direction.lerp(to_center, 0.7).normalized()
	elif min_distance < boundary_margin * 2:
		# Недалеко от границы — слегка подправляем направление
		walk_direction = walk_direction.lerp(to_center, 0.3).normalized()


func _on_idle_timer_timeout() -> void:
	if current_state == State.IDLE:
		enter_walk_state()


func _on_walk_timer_timeout() -> void:
	if current_state == State.WALKING:
		enter_idle_state()


func _on_direction_timer_timeout() -> void:
	if current_state == State.WALKING:
		if rng.randf() < change_direction_chance:
			choose_random_direction()
		
		direction_timer.start(rng.randf_range(0.5, 1.5))


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state != State.FLEEING:
		dialog()


func clamp_to_boundaries() -> void:
	if not use_boundaries:
		return
	
	global_position.x = clamp(global_position.x, boundary_min.x, boundary_max.x)
	global_position.y = clamp(global_position.y, boundary_min.y, boundary_max.y)


func dialog():
	#if Input.is_action_just_pressed("action"):
		var dialog = get_tree().get_first_node_in_group("dialog")
		dialog.open_dialog()
