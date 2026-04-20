extends Node

var save_path = "user://game.save"

var player: Player = null
var health_component: HealthComponent = null
var stamina_component: StaminaComponent = null
var experience_manager: ExperienceManager = null


func _ready() -> void:
	# Даём время на инициализацию сцены
	await get_tree().process_frame
	initialize_references()
	
	# Загружаем сохранение если есть
	if FileAccess.file_exists(save_path):
		load_game()
	else:
		print("Файл сохранения не найден")


func initialize_references() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player:
		health_component = player.find_child("HealthComponent", true, false)
		stamina_component = player.find_child("StaminaComponent", true, false)
		print("Игрок найден")
	else:
		print("Игрок НЕ найден!")
	
	experience_manager = get_tree().get_first_node_in_group("experience_manager")
	if experience_manager:
		print("ExperienceManager найден")
	else:
		print("ExperienceManager НЕ найден!")


func save_game() -> void:
	# Проверяем, что ссылки актуальны
	if not player:
		initialize_references()
		if not player:
			printerr("Нет ссылки на игрока! Сохранение невозможно.")
			return
	
	# Создаём словарь с актуальными данными
	var data_to_save: Dictionary = {
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"current_health": health_component.current_health if health_component else 100,
		"max_health": health_component.max_health if health_component else 100,
		"current_stamina": stamina_component.current_stamina if stamina_component else 100,
		"max_stamina": stamina_component.max_stamina if stamina_component else 100,
		"current_exp": experience_manager.current_experience if experience_manager else 0,
		"target_exp": experience_manager.target_experience if experience_manager else 5,
		"level": experience_manager.current_level if experience_manager else 1
	}
	
	print("Сохраняем данные:", data_to_save)
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(data_to_save)
		file.close()
		print("Игра сохранена! Путь: ", ProjectSettings.globalize_path(save_path))
	else:
		printerr("Ошибка создания файла сохранения!")


func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		print("Файл сохранения не найден")
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var loaded_data = file.get_var()
		file.close()
		print("Загружены данные:", loaded_data)
		
		# Ждём инициализации если нужно
		if not player:
			await get_tree().process_frame
			initialize_references()
		
		# Применяем данные
		if player:
			player.global_position = Vector2(loaded_data["position_x"], loaded_data["position_y"])
		
		if health_component:
			health_component.current_health = loaded_data["current_health"]
			health_component.max_health = loaded_data["max_health"]
		
		if stamina_component:
			stamina_component.current_stamina = loaded_data["current_stamina"]
			stamina_component.max_stamina = loaded_data["max_stamina"]
		
		if experience_manager:
			experience_manager.current_experience = loaded_data["current_exp"]
			experience_manager.target_experience = loaded_data["target_exp"]
			experience_manager.current_level = loaded_data["level"]
		
		print("Данные применены!")
	else:
		printerr("Ошибка открытия файла!")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):  # Клавиша F5
		save_game()
	elif event.is_action_pressed("load"):  # Клавиша F9
		load_game()


# Автосохранение при выходе
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
