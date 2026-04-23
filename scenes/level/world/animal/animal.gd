# animal.gd
extends CharacterBody2D

enum State {
	IDLE,
	WALKING
}

@export var walk_speed: float = 50.0
@export var idle_time_min: float = 2.0
@export var idle_time_max: float = 5.0
@export var walk_time_min: float = 1.0
@export var walk_time_max: float = 4.0
@export var change_direction_chance: float = 0.3

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_timer: Timer = $IdleTimer
@onready var walk_timer: Timer = $WalkTimer
@onready var direction_timer: Timer = $DirectionTimer

var current_state: State = State.IDLE
var walk_direction: Vector2 = Vector2.ZERO
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	
	# Настройка таймеров
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	
	walk_timer.one_shot = true
	walk_timer.timeout.connect(_on_walk_timer_timeout)
	
	direction_timer.one_shot = true
	direction_timer.timeout.connect(_on_direction_timer_timeout)
	
	# Начинаем в состоянии покоя
	enter_idle_state()


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
		
		State.WALKING:
			velocity = walk_direction * walk_speed
			animated_sprite.play("walk")
			
			# Поворачиваем спрайт по направлению движения
			if walk_direction.x != 0:
				animated_sprite.scale.x = sign(-walk_direction.x)
	
	move_and_slide()


func enter_idle_state() -> void:
	current_state = State.IDLE
	idle_timer.start(rng.randf_range(idle_time_min, idle_time_max))


func enter_walk_state() -> void:
	current_state = State.WALKING
	choose_random_direction()
	walk_timer.start(rng.randf_range(walk_time_min, walk_time_max))
	direction_timer.start(rng.randf_range(0.5, 1.5))


func choose_random_direction() -> void:
	var angle = rng.randf_range(0, TAU)
	walk_direction = Vector2.RIGHT.rotated(angle)


func _on_idle_timer_timeout() -> void:
	enter_walk_state()


func _on_walk_timer_timeout() -> void:
	enter_idle_state()


func _on_direction_timer_timeout() -> void:
	if current_state == State.WALKING:
		# Шанс сменить направление во время ходьбы
		if rng.randf() < change_direction_chance:
			choose_random_direction()
		
		direction_timer.start(rng.randf_range(0.5, 1.5))


# Взаимодействие с игроком
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Реакция на игрока (убегание или любопытство)
		react_to_player(body)


func react_to_player(player: Node2D) -> void:
	# Убегаем от игрока
	var flee_direction = (global_position - player.global_position).normalized()
	walk_direction = flee_direction
	walk_speed *= 1.5  # Ускоряемся при убегании
	
	# Через некоторое время успокаиваемся
	await get_tree().create_timer(2.0).timeout
	walk_speed /= 1.5
	enter_idle_state()
