extends CharacterBody2D

signal player_entered(npc)
signal player_exited(npc)
var SPEED = 300

@onready var reply_label = $Label

func _ready():
	reply_label.visible = false
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("player_entered", self)

func _on_body_exited(body):
	if body.name == "Player":
		emit_signal("player_exited", self)

func show_reply(text: String):
	reply_label.text = text
	reply_label.visible = true
