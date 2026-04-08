extends CanvasLayer
class_name MiniProfile

@onready var nine_patch = $NinePatchRect
@onready var icon = $NinePatchRect/TextureRect
@onready var level_label = $NinePatchRect/Label
@onready var v_box_container: VBoxContainer = $NinePatchRect/VBoxContainer
@onready var hp_bar: TextureProgressBar = $NinePatchRect/VBoxContainer/hp_bar
@onready var stamina_bar: TextureProgressBar = $NinePatchRect/VBoxContainer/stamina_bar

var experience_manager: ExperienceManager
var player = null
var player_health_component = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	
	player_health_component = player.get_node("HealthComponent")
	if !player_health_component:
		return
	
	player_health_component.health_decreased.connect(on_player_health_changed)
	player_health_component.health_increased.connect(on_player_health_changed)
	
	update_health_bar(player_health_component)
	
	experience_manager = get_tree().get_first_node_in_group("experience_manager")

func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	
	player_health_component = player.get_node("HealthComponent")
	if player_health_component:
		update_health_bar(player_health_component)

func on_player_health_changed():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var health_comp = player.get_node("HealthComponent")
		update_health_bar(health_comp)

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
		
		# Визуальный эффект при низкой стамине
		var percent = (current_stamina / max_stamina) * 100
		if percent < 20:
			stamina_bar.modulate = Color(1, 0.5, 0.5)
		elif percent < 50:
			stamina_bar.modulate = Color(1, 0.8, 0.5)
		else:
			stamina_bar.modulate = Color(1, 1, 1)
