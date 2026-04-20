extends Node
var save_path = "user://game.save"
var cached_data: Dictionary = {}
var pending_load: bool = false

func _ready() -> void:
	# Загружаем данные с диска при первом запуске
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			cached_data = file.get_var()
			file.close()

func _process(delta: float) -> void:
	# Ждём, пока в новой сцене появится игрок, затем применяем данные
	if pending_load:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			_apply_data()
			pending_load = false
			print("✅ Прогресс загружен в новую сцену!")

# Вызывается ПЕРЕД сменой сцены
func save_state() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	var hc = player.find_child("HealthComponent", true, false)
	var sc = player.find_child("StaminaComponent", true, false)
	var em = get_tree().get_first_node_in_group("experience_manager")

	cached_data = {
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"current_health": hc.current_health if hc else 100,
		"max_health": hc.max_health if hc else 100,
		"current_stamina": sc.current_stamina if sc else 100,
		"max_stamina": sc.max_stamina if sc else 100,
		"current_exp": em.current_experience if em else 0,
		"target_exp": em.target_experience if em else 5,
		"level": em.current_level if em else 1
	}

	# Дублируем в файл для надёжности (выход, краши)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(cached_data)
		file.close()

# Вызывается при загрузке из меню или переходе между сценами
func request_load() -> void:
	pending_load = true

func _apply_data() -> void:
	if cached_data.is_empty(): return

	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	var hc = player.find_child("HealthComponent", true, false)
	var sc = player.find_child("StaminaComponent", true, false)
	var em = get_tree().get_first_node_in_group("experience_manager")

	player.global_position = Vector2(cached_data.get("position_x", 0.0), cached_data.get("position_y", 0.0))
	if hc:
		hc.current_health = cached_data.get("current_health", 100)
		hc.max_health = cached_data.get("max_health", 100)
	if sc:
		sc.current_stamina = cached_data.get("current_stamina", 100)
		sc.max_stamina = cached_data.get("max_stamina", 100)
	if em:
		em.current_experience = cached_data.get("current_exp", 0)
		em.target_experience = cached_data.get("target_exp", 5)
		em.current_level = cached_data.get("level", 1)

# Горячие клавиши (опционально)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save_state()
		print("💾 Ручное сохранение (F5)")
	elif event.is_action_pressed("load"):
		request_load()
		print("📥 Ручная загрузка (F9)")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_state()
