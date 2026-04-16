extends Node2D

@export var health_component: HealthComponent
@export var stamina_component: StaminaComponent
@export var shield_duration: float = 5.0
@export var stamina_cost: float = 50.0
@export var shield_area_radius: float = 100.0

@onready var timer: Timer = $Timer
@onready var shield_timer: Timer = $ShieldTimer
@onready var shield_visual: Node2D = $ShieldVisual
@onready var shield_area_2d: Area2D = $ShieldArea2D

var is_on_cooldown = false
var is_shield_active = false
var player: Node2D = null

func _ready() -> void:
	# 1. Убрали 'var', чтобы не затенять классовую переменную
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("Не найден игрок в группе 'player'!")
		return

	# Таймер кулдауна
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(on_cooldown_finished)

	# Таймер длительности щита
	shield_timer.autostart = false
	shield_timer.one_shot = true
	shield_timer.wait_time = shield_duration # Используем экспорт
	shield_timer.timeout.connect(deactive_shield)

	if shield_area_2d:
		var collision_shape = shield_area_2d.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = shield_area_radius

		# 2. Подключаем сигнал для отталкивания врагов
		shield_area_2d.body_entered.connect(_on_shield_body_entered)

		shield_area_2d.monitoring = false
		shield_area_2d.monitorable = false

	if shield_visual:
		shield_visual.visible = false

	# 3. Если щит добавлен как дочерний узел игрока, центрируем его
	position = Vector2.ZERO


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("4"):
		perform_shield()

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("4"):
		#perform_shield()

func perform_shield():
	if is_on_cooldown or is_shield_active:
		return

	# Проверяем и расходуем стамину
	if stamina_component:
		stamina_component.use_stamina(stamina_cost)

	is_shield_active = true
	if shield_visual:
		shield_visual.visible = true
		#shield_visual.a
	if shield_area_2d:
		shield_area_2d.monitoring = true
		shield_area_2d.monitorable = false

	# 4. Запускаем оба таймера
	shield_timer.start()
	start_cooldown()

func start_cooldown():
	is_on_cooldown = true
	timer.start()

func on_cooldown_finished():
	is_on_cooldown = false
	print("Щит готов к использованию")

func deactive_shield():
	is_shield_active = false
	if shield_visual:
		shield_visual.visible = false
	if shield_area_2d:
		shield_area_2d.monitoring = false
		shield_area_2d.monitorable = false
	print("Щит деактивирован")

# 5. Обработка коллизий: отталкиваем врагов за границу щита
func _on_shield_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var direction = body.global_position - global_position
		if direction.length() > 0:
			direction = direction.normalized()
			# Телепортируем врага на край щита
			body.global_position = global_position + direction * shield_area_radius
