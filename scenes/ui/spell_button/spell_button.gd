extends TextureButton

@onready var cooldown_bar: TextureProgressBar = $CooldownBar
@onready var key_button: Label = $KeyButton
@onready var time_button: Label = $TimeButton
@onready var timer: Timer = $Timer

var skill = null

var change_key = "":
	set(value):
		change_key = value
		key_button.text = value
		
		shortcut = Shortcut.new()
		var input_key = InputEventKey.new()
		input_key.keycode = value.unicode_at(0)
		
		shortcut.events = [input_key]


func _ready() -> void:
	change_key = "1"
	cooldown_bar.max_value = timer.wait_time
	set_process(false)


func _process(delta: float) -> void:
	time_button.text = "%3.1f" % timer.time_left
	cooldown_bar.value = timer.time_left


func _on_pressed() -> void:
	timer.start()
	disabled = true
	set_process(true)


func _on_timer_timeout() -> void:
	disabled = false
	time_button.text = ""
	cooldown_bar.value = 0
	set_process(false)
