extends Node

@export var attack_ability: PackedScene
@export_enum("None", "Physical", "Fire", "Electric") var damage_type: String = "Physical"
@export var base_damage: float = 200.0
@export var crit_chance: float = 0.1  # 10% шанс крита

@onready var timer: Timer = $Timer

var attack_range = 100
var damage = 10
var damage_multiplier = 1
var default_attack_speed
var is_on_cooldown: bool = false  # Флаг для отслеживания кулдауна


func _ready() -> void:
	Global.ability_upgrade_added.connect(on_upgrade_added)
	default_attack_speed = timer.wait_time # 1.5 sec
	timer.one_shot = true  # Важно! Таймер должен быть одноразовым
	timer.timeout.connect(on_cooldown_finished)  # Подключаем сигнал окончания

func _process(delta):
	# Проверяем нажатие клавиши атаки
	if Input.is_action_just_pressed("left_click"):
		attempt_attack()

func attempt_attack():
	# Проверяем, не на кулдауне ли атака
	if is_on_cooldown:
		print("Атака на перезарядке!")
		return
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player: 
		return 
	
	# Получаем врагов в радиусе атаки
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	enemies = enemies.filter(func(enemy:Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(attack_range, 2)
	)
	
	if enemies.is_empty():
		print("Нет врагов в радиусе атаки!")
		return
	
	# Сортируем врагов по расстоянию (ближайший первый)
	enemies.sort_custom(func(a:Node2D, b:Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	
	# Выполняем атаку
	perform_attack(player, enemies[0])
	
	# Запускаем кулдаун
	start_cooldown()


func perform_attack(player: Node2D, target_enemy: Node2D):
	var attack_instance = attack_ability.instantiate() as AttackAbility
	var front_layer = get_tree().get_first_node_in_group("front_layer")
	front_layer.add_child(attack_instance)
	
	# Получаем компонент получения урона у врага
	var damage_receiver = target_enemy.find_child("DamageReceiver", true, false)
	
	if damage_receiver:
		# Враг сам посчитает свой урон с учётом защиты
		var final_damage = damage_receiver.take_damage(
			base_damage * damage_multiplier,
			damage_type,
			crit_chance
		)
		
		## Устанавливаем урон для визуального эффекта атаки
		#if attack_instance.has_method("set_damage_display"):
			#attack_instance.set_damage_display(final_damage)
	else:
		print("ОШИБКА: У врага нет компонента DamageReceiver!")
	
	# Позиционируем атаку
	attack_instance.global_position = (target_enemy.global_position + player.global_position) / 2
	attack_instance.look_at(target_enemy.global_position)
	
	print("Атака по %s | Урон: %.1f" % [target_enemy.name, base_damage * damage_multiplier])


func start_cooldown():
	"""Запускает кулдаун атаки"""
	is_on_cooldown = true
	timer.start()  # Запускаем таймер с текущим wait_time
	# Опционально: визуальный индикатор кулдауна
	update_ui_cooldown(true)

func on_cooldown_finished():
	"""Вызывается, когда кулдаун закончился"""
	is_on_cooldown = false
	print("Атака готова!")
	# Опционально: обновляем UI
	update_ui_cooldown(false)

func update_ui_cooldown(on_cooldown: bool):
	# Здесь можно обновить интерфейс (например, затемнить иконку способности)
	# Если у вас есть UI для отображения кулдауна
	pass

func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_rate":
		var upgrade_percent = current_upgrades["sword_rate"]["quantity"] * .1
		# Обновляем время кулдауна
		timer.wait_time = max(0.1, default_attack_speed * (1 - upgrade_percent))
		print("Скорость атаки обновлена: ", timer.wait_time)
	
	elif upgrade.id == "sword_damage":
		damage_multiplier = 1.0 + (current_upgrades["sword_damage"]["quantity"] * .15)
		print("Множитель урона обновлен: ", damage_multiplier)

# Опционально: метод для принудительного сброса кулдауна
func reset_cooldown():
	"""Сбрасывает кулдаун (полезно для тестирования или чит-кодов)"""
	is_on_cooldown = false
	timer.stop()
	update_ui_cooldown(false)
