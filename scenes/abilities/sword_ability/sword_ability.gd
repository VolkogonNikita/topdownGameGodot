extends Node

@export var charge_time: float = 6.0
@export var crit_bonus_multiplier: float = 2.5

@onready var charge_timer: Timer = $ChargeTimer if $ChargeTimer else null

var is_crit_charged: bool = false
signal crit_charged()
signal crit_used()

var attack_controller: Node = null

func _ready() -> void:
	add_to_group("sword_ability")
	# 1. Надёжная инициализация таймера
	if not charge_timer:
		charge_timer = Timer.new()
		charge_timer.name = "ChargeTimer"
		add_child(charge_timer)
		
	charge_timer.wait_time = charge_time
	charge_timer.one_shot = true # Ручной контроль зарядки
	charge_timer.timeout.connect(on_crit_charged)
	charge_timer.start() # Явный запуск

	# 2. Безопасное подключение (обходим race condition)
	call_deferred("connect_to_controller")

func connect_to_controller():
	attack_controller = get_tree().get_first_node_in_group("attack_controller")
	if not attack_controller:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			attack_controller = player.find_child("AttackController", true, false)
			
	if attack_controller and attack_controller.has_signal("attack_performed"):
		if not attack_controller.attack_performed.is_connected(on_attack_performed):
			attack_controller.attack_performed.connect(on_attack_performed)
	else:
		printerr("[SwordAbility] Не удалось найти AttackController для подключения!")

func on_crit_charged():
	if is_crit_charged: return
	is_crit_charged = true
	crit_charged.emit()
	print("[SwordAbility] ⚡ Гарантированный крит заряжен!")

func on_attack_performed(was_crit: bool):
	if is_crit_charged and was_crit:
		is_crit_charged = false
		crit_used.emit()
		print("[SwordAbility] 🎯 Гарантированный крит использован!")
		charge_timer.start() # Перезапускаем зарядку только после использования
	elif is_crit_charged and not was_crit:
		print("[SwordAbility] ⚠️ Атака была не критической. Заряд сохранён.")

func is_crit_ready() -> bool:
	return is_crit_charged

func get_crit_multiplier() -> float:
	return crit_bonus_multiplier if is_crit_charged else 2.0
