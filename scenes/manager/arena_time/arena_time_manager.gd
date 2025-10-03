#added to diagram
extends Node

@onready var timer = $Timer

func get_time_elapsed():
	return $Timer.wait_time - $Timer.time_left
