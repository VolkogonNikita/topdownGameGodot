extends Node2D
class_name Rain

enum State {
	IDLE,
	WALKING
}

@export var idle_time_min: float = 2.0
@export var idle_time_max: float = 5.0
@export var walk_time_min: float = 4.0
@export var walk_time_max: float = 15.0

@onready var idle_timer: Timer = $IdleTimer
@onready var walk_timer: Timer = $WalkTimer

var current_state: State = State.IDLE
var rng = RandomNumberGenerator.new()

signal is_raining()
signal isnt_raining()

func _ready() -> void:
	rng.randomize()
	
	# Настройка таймеров
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	
	walk_timer.one_shot = true
	walk_timer.timeout.connect(_on_walk_timer_timeout)
	
	# Начинаем в состоянии покоя
	enter_idle_state()


func enter_idle_state() -> void:
	current_state = State.IDLE
	idle_timer.start(rng.randf_range(idle_time_min, idle_time_max))
	$CPUParticles2D.emitting = false
	isnt_raining.emit()


func enter_walk_state() -> void:
	current_state = State.WALKING
	walk_timer.start(rng.randf_range(walk_time_min, walk_time_max))
	$CPUParticles2D.emitting = true
	is_raining.emit()


func _on_idle_timer_timeout() -> void:
	enter_walk_state()


func _on_walk_timer_timeout() -> void:
	enter_idle_state()
