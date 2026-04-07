extends Control

@onready var inv: Inv = preload("res://scenes/ui/final_ui/items/players_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open: bool = false

func _ready() -> void:
	inv.update.connect(on_update_slots)
	#fupdate_slots()
	close()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("b"):
		if is_open: close()
		else: open()


func open():
	print("open")
	self.is_open = true
	visible = true


func close():
	print("close")
	is_open = false
	visible = false


func on_update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])
