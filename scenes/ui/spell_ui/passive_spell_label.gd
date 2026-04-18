extends Label

@onready var cooldown_bar: TextureProgressBar = $CooldownBar
@onready var time_label: Label = $TimeButton  # Переименовал для ясности
@onready var timer: Timer = $Timer

var skill = null
var sword_ability: Node = null
var is_crit_on_cooldown: bool = false  # Флаг состояния кулдауна

func _ready() -> void:
	cooldown_bar.max_value = timer.wait_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	set_process(false)
	call_deferred("connect_to_controller")


func _process(delta: float) -> void:
	if is_crit_on_cooldown:
		time_label.text = "%3.1f" % timer.time_left
		cooldown_bar.value = timer.time_left


func connect_to_controller():
	sword_ability = get_tree().get_first_node_in_group("sword_ability")
	if not sword_ability:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			sword_ability = player.find_child("SwordAbility", true, false)
			
	if sword_ability and sword_ability.has_signal("crit_used"):
		# ИСПРАВЛЕНО: Правильное подключение сигнала
		if not sword_ability.crit_used.is_connected(_on_crit_used):
			sword_ability.crit_used.connect(_on_crit_used)
	else:
		printerr("[SwordAbility] Не удалось найти SwordAbility или сигнал crit_used!")


func _on_crit_used():
	"""Вызывается когда крит был использован"""
	is_crit_on_cooldown = true
	timer.start()
	set_process(true)


func _on_timer_timeout() -> void:
	is_crit_on_cooldown = false
	time_label.text = ""
	cooldown_bar.value = 0
	set_process(false)
