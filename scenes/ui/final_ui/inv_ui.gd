extends Control

@onready var inv: Inv = preload("res://scenes/ui/final_ui/items/players_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open: bool = false

func _ready() -> void:
	update_slots()
	close()


func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])


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
