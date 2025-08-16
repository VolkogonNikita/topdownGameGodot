extends CanvasLayer

@export var arena_time_manager: Node

func _process(delta: float) -> void:
	if !arena_time_manager:
		return
	var time_elapsed = arena_time_manager.get_time_elapsed()
	$MarginContainer/Label.text = format_timer(time_elapsed)

func format_timer(seconds: float):
	var minutes = floor(seconds/60)
	var remaining_seconds = seconds - (minutes * 60)
	return "%02d:%02d" % [minutes, floor(remaining_seconds)]
	
