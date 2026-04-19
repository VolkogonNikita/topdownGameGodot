extends CanvasLayer
class_name MiniProfile

@onready var nine_patch = $NinePatchRect
@onready var icon = $NinePatchRect/TextureRect
@onready var level_label = $NinePatchRect/Label
@onready var v_box_container: VBoxContainer = $NinePatchRect/VBoxContainer
@onready var hp_bar: TextureProgressBar = $NinePatchRect/VBoxContainer/hp_bar
@onready var stamina_bar: TextureProgressBar = $NinePatchRect/VBoxContainer/stamina_bar
@onready var exp_bar: TextureProgressBar = $NinePatchRect/VBoxContainer/exp_bar

var experience_manager: ExperienceManager
var player = null
var player_health_component = null


func _ready():
	player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	
	player_health_component = player.get_node("HealthComponent")
	if player_health_component:
		player_health_component.get_damage.connect(on_player_health_changed)
		player_health_component.get_heal.connect(on_player_health_changed)
		update_health_bar(player_health_component)
	
	experience_manager = get_tree().get_first_node_in_group("experience_manager")
	
	# Подключаем сигнал обновления опыта, если есть
	if experience_manager and experience_manager.has_signal("experience_update"):
		experience_manager.experience_update.connect(_on_experience_updated)
	
	update_exp_bar()


func _process(_delta: float) -> void:
	# Не нужно каждый кадр искать игрока и health_component
	# Это снижает производительность
	if player and player_health_component:
		update_health_bar(player_health_component)
	
	update_exp_bar()


func on_player_health_changed(_amount = null):
	if player_health_component:
		update_health_bar(player_health_component)


func _on_experience_updated(_current: float, _target: float):
	update_exp_bar()


func update_health_bar(health_comp):
	if health_comp and hp_bar:
		hp_bar.max_value = health_comp.max_health
		hp_bar.value = health_comp.current_health
		
		var percent = (health_comp.current_health / health_comp.max_health) * 100
		if percent < 30:
			hp_bar.modulate = Color(1, 0.8, 0.8)
		else:
			hp_bar.modulate = Color(1, 1, 1)


func update_stamina_bar(current_stamina: float, max_stamina: float):
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina
		
		var percent = (current_stamina / max_stamina) * 100
		if percent < 20:
			stamina_bar.modulate = Color(1, 0.5, 0.5)
		elif percent < 50:
			stamina_bar.modulate = Color(1, 0.8, 0.5)
		else:
			stamina_bar.modulate = Color(1, 1, 1)


func update_exp_bar():
	# ДОБАВЛЕНА ПРОВЕРКА НА null
	if not experience_manager:
		return
	
	if exp_bar:
		exp_bar.max_value = experience_manager.target_experience
		exp_bar.value = experience_manager.current_experience
