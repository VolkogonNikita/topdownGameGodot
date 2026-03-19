extends CanvasLayer

@onready var health_bar: ProgressBar = $NinePatchRect/VBoxContainer/HealthBar
@onready var nine_patch = $NinePatchRect
#@onready var health_bar = $NinePatchRect/VBoxContainer/ProgressBar
@onready var exp_bar = $NinePatchRect/VBoxContainer/ProgressBar2
@onready var icon = $NinePatchRect/TextureRect
@onready var level_label = $NinePatchRect/Label
#@onready var texture_rect: TextureRect = $NinePatchRect/TextureRect
@onready var v_box_container: VBoxContainer = $NinePatchRect/VBoxContainer

var player = null
var player_health_component = null
var profile_width: int = 60  # Ширина профиля
var profile_height: int = 16  # Высота профиля
var icon_size: int = 10       # Размер иконки
var bar_height: int = 12      # Высота полосок


func _ready():
	setup_style()
	setup_position()
	setup_size()
	
	player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	
	player_health_component = player.get_node("HealthComponent")
	if !player_health_component:
		print("пошёл нахуй")
		return

	player_health_component.health_decreased.connect(on_player_health_changed)
	player_health_component.health_increased.connect(on_player_health_changed)
	#health_update()
	update_health_bar(player_health_component)

#func health_update():
	#if player_health_component:
		#health_bar.value = player_health_component.get_health_value() * 100
##		var health_text = str(player_health_component.current_health) + "/" + str(player_health_component.max_health)

func setup_size():
	if nine_patch:
		# Устанавливаем размер профиля
		nine_patch.size = Vector2(profile_width, profile_height)
		
		# Настраиваем минимальный размер
		nine_patch.custom_minimum_size = Vector2(profile_width, profile_height)
	
	if v_box_container:
		# Настраиваем отступы внутри (меньше для компактности)
		v_box_container.add_theme_constant_override("separation", 4)
		v_box_container.add_theme_constant_override("margin_left", 6)
		v_box_container.add_theme_constant_override("margin_right", 6)
		v_box_container.add_theme_constant_override("margin_top", 6)
		v_box_container.add_theme_constant_override("margin_bottom", 6)


func setup_style():
	# Настройка NinePatchRect (фон)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)  # Темный фон
	bg_style.corner_radius_top_left = 10
	bg_style.corner_radius_top_right = 10
	bg_style.corner_radius_bottom_left = 10
	bg_style.corner_radius_bottom_right = 10
	bg_style.shadow_color = Color(0, 0, 0, 0.5)
	bg_style.shadow_size = 10
	bg_style.shadow_offset = Vector2(2, 2)
	nine_patch.add_theme_stylebox_override("panel", bg_style)
	
	# Настройка полоски здоровья
	var health_bg = StyleBoxFlat.new()
	health_bg.bg_color = Color(0.2, 0.2, 0.25)
	health_bg.corner_radius_top_left = 5
	health_bg.corner_radius_top_right = 5
	health_bg.corner_radius_bottom_left = 5
	health_bg.corner_radius_bottom_right = 5
	
	var health_fill = StyleBoxFlat.new()
	health_fill.bg_color = Color(1, 0.3, 0.3)  # Красный
	health_fill.corner_radius_top_left = 5
	health_fill.corner_radius_top_right = 5
	health_fill.corner_radius_bottom_left = 5
	health_fill.corner_radius_bottom_right = 5
	
	health_bar.add_theme_stylebox_override("background", health_bg)
	health_bar.add_theme_stylebox_override("fill", health_fill)
	
	# Настройка полоски опыта
	var exp_bg = StyleBoxFlat.new()
	exp_bg.bg_color = Color(0.2, 0.2, 0.25)
	exp_bg.corner_radius_top_left = 5
	exp_bg.corner_radius_top_right = 5
	exp_bg.corner_radius_bottom_left = 5
	exp_bg.corner_radius_bottom_right = 5
	
	var exp_fill = StyleBoxFlat.new()
	exp_fill.bg_color = Color(0.3, 0.6, 1)  # Голубой
	exp_fill.corner_radius_top_left = 5
	exp_fill.corner_radius_top_right = 5
	exp_fill.corner_radius_bottom_left = 5
	exp_fill.corner_radius_bottom_right = 5
	
	exp_bar.add_theme_stylebox_override("background", exp_bg)
	exp_bar.add_theme_stylebox_override("fill", exp_fill)
	
	# Настройка иконки
	icon.modulate = Color(1, 1, 1, 1)
	icon.expand = true
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Настройка текста
	#var font = SystemFont.new()
	##font.font_size = 14
	#font.font_names = ["Arial", "Verdana", "sans-serif"]
	#font.outline_size = 1
	#font.outline_color = Color(0, 0, 0, 0.8)
	#
	#level_label.add_theme_font_override("font", font)
	#level_label.add_theme_color_override("font_color", Color(1, 1, 1))
	#level_label.add_theme_constant_override("shadow_offset_x", 1)
	#level_label.add_theme_constant_override("shadow_offset_y", 1)
	#level_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))


func setup_position():
	# Позиционируем в левом верхнем углу с отступами
	nine_patch.position = Vector2(20, 20)
	
	# Настраиваем размеры
	nine_patch.size = Vector2(250, 100)  # Подберите под свой дизайн
	
	# Отступы внутри NinePatchRect
	var margin = nine_patch.get_node("VBoxContainer")
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)


#func on_player_health_changed():
	#health_update()

func on_player_health_changed():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var health_comp = player.get_node("HealthComponent")
		update_health_bar(health_comp)

func update_health_bar(health_comp):
	if health_comp:
		var percent = (health_comp.current_health / health_comp.max_health) * 100
		health_bar.value = percent
		
		# Анимация при получении урона
		if percent < 30:
			health_bar.modulate = Color(1, 0.8, 0.8)  # Красноватый оттенок при низком здоровье
		else:
			health_bar.modulate = Color(1, 1, 1)
