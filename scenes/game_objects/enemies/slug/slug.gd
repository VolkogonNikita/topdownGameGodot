# slug.gd
extends CharacterBody2D

enum State {
	IDLE,
	WALKING,
	CHASING
}

@export var walk_speed: float = 50.0
@export var chase_speed: float = 100.0
@export var idle_time_min: float = 2.0
@export var idle_time_max: float = 5.0
@export var walk_time_min: float = 1.0
@export var walk_time_max: float = 4.0
@export var change_direction_chance: float = 0.3

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_timer: Timer = $IdleTimer
@onready var walk_timer: Timer = $WalkTimer
@onready var direction_timer: Timer = $DirectionTimer

@onready var movement_component: Node = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var detection_area: Area2D = $Detection  # Добавлено!

var current_state: State = State.IDLE
var walk_direction: Vector2 = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var player: Player = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	# Подключаем сигналы
	health_component.died.connect(on_died)
	
	# Настройка Detection Area
	if detection_area:
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
	
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
			if animated_sprite.sprite_frames.has_animation("idle"):
				animated_sprite.play("idle")
		
		State.WALKING:
			velocity = walk_direction * walk_speed
			if animated_sprite.sprite_frames.has_animation("walk"):
				animated_sprite.play("walk")
			
			if walk_direction.x != 0:
				animated_sprite.scale.x = sign(walk_direction.x)
		
		State.CHASING:
			if player:
				var direction_to_player = movement_component.get_direction()
				movement_component.move_to_player(self)
				if animated_sprite.sprite_frames.has_animation("walk"):
					animated_sprite.play("walk")
				
				if direction_to_player.x != 0:
					animated_sprite.scale.x = sign(direction_to_player.x)
	
	move_and_slide()


func enter_idle_state() -> void:
	current_state = State.IDLE
	idle_timer.start(rng.randf_range(idle_time_min, idle_time_max))


func enter_walk_state() -> void:
	current_state = State.WALKING
	choose_random_direction()
	walk_timer.start(rng.randf_range(walk_time_min, walk_time_max))
	direction_timer.start(rng.randf_range(0.5, 1.5))


func enter_chase_state() -> void:
	current_state = State.CHASING


func choose_random_direction() -> void:
	var angle = rng.randf_range(0, TAU)
	walk_direction = Vector2.RIGHT.rotated(angle)


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


func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Slug заметил игрока!")
		enter_chase_state()


func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == State.CHASING:
		print("Slug потерял игрока")
		enter_idle_state()


func on_died():
	queue_free()
