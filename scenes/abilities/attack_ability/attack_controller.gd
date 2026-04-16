extends Node

@export var attack_ability: PackedScene
@export_enum("None", "Physical", "Fire", "Electric") var damage_type: String = "Physical"
@export var base_damage: float = 200.0
@export var crit_chance: float = 0.0

@onready var timer: Timer = $Timer

var attack_range: float = 100.0
var damage_multiplier: float = 1.0
var default_attack_speed: float
var is_on_cooldown: bool = false
var sword_ability: Node = null

signal attack_performed(was_crit: bool)

func _ready() -> void:
	add_to_group("attack_controller")
	if Global: Global.ability_upgrade_added.connect(on_upgrade_added)
	
	default_attack_speed = timer.wait_time
	timer.one_shot = true
	timer.timeout.connect(on_cooldown_finished)
	
	# Безопасный поиск SwordAbility
	call_deferred("find_sword_ability")

func find_sword_ability():
	sword_ability = get_tree().get_first_node_in_group("sword_ability")
	if not sword_ability:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			sword_ability = player.find_child("SwordAbility", true, false)
			
	if sword_ability:
		print("[AttackController] ✅ SwordAbility подключен.")
	else:
		printerr("[AttackController] ❌ SwordAbility не найден!")

# 3. Перенос ввода в _unhandled_input (Godot Best Practice)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		attempt_attack()

func attempt_attack():
	if is_on_cooldown: return

	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player: return

	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(e: Node2D): 
		return e.global_position.distance_squared_to(player.global_position) < attack_range * attack_range)
		
	if enemies.is_empty(): return

	enemies.sort_custom(func(a: Node2D, b: Node2D):
		return a.global_position.distance_squared_to(player.global_position) < b.global_position.distance_squared_to(player.global_position))

	perform_attack(player, enemies[0])
	start_cooldown()

func perform_attack(player: Node2D, target_enemy: Node2D):
	var attack_instance = attack_ability.instantiate() as AttackAbility
	var front_layer = get_tree().get_first_node_in_group("front_layer")
	if front_layer: front_layer.add_child(attack_instance)

	var damage_receiver = target_enemy.find_child("DamageReceiver", true, false)
	if not damage_receiver:
		printerr("ОШИБКА: У врага нет компонента DamageReceiver!")
		return

	var is_crit: bool = check_if_crit()
	var has_guaranteed_crit: bool = false

	if sword_ability and sword_ability.has_method("is_crit_ready"):
		has_guaranteed_crit = sword_ability.is_crit_ready()

	if has_guaranteed_crit:
		is_crit = true
		print("[AttackController] 🔥 АКТИВИРОВАН ГАРАНТИРОВАННЫЙ КРИТ!")
	elif is_crit:
		print("[AttackController] 💥 Обычный крит по шансу!")

	# Передаём 100% шанс крита, если он гарантирован
	damage_receiver.take_damage(
		base_damage * damage_multiplier,
		damage_type,
		1.0 if is_crit else crit_chance
	)

	attack_performed.emit(is_crit)

	if attack_instance:
		attack_instance.global_position = (target_enemy.global_position + player.global_position) / 2.0
		attack_instance.look_at(target_enemy.global_position)

func check_if_crit() -> bool:
	return randf() < crit_chance

func start_cooldown():
	is_on_cooldown = true
	timer.start()

func on_cooldown_finished():
	is_on_cooldown = false

func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_rate":
		var upgrade_percent = current_upgrades["sword_rate"]["quantity"] * 0.1
		timer.wait_time = max(0.1, default_attack_speed * (1.0 - upgrade_percent))
		print("⏱ Скорость атаки обновлена: ", timer.wait_time)
	elif upgrade.id == "sword_damage":
		damage_multiplier = 1.0 + (current_upgrades["sword_damage"]["quantity"] * 0.15)
		print("📈 Множитель урона обновлен: ", damage_multiplier)

func reset_cooldown():
	is_on_cooldown = false
	timer.stop()
