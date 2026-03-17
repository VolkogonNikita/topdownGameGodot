extends CanvasLayer

@onready var progress_bar: ProgressBar = $NinePatchRect/VBoxContainer/ProgressBar

var player = null
var player_health_component = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	
	player_health_component = player.get_node("HealthComponent")
	if !player_health_component:
		print("пошёл нахуй")
		return 

	player_health_component.health_decreased.connect(on_player_health_changed)
	player_health_component.health_increased.connect(on_player_health_changed)
	health_update()


func health_update():
	if player_health_component:
		progress_bar.value = player_health_component.get_health_value() * 100
#		var health_text = str(player_health_component.current_health) + "/" + str(player_health_component.max_health)


func on_player_health_changed():
	health_update()
