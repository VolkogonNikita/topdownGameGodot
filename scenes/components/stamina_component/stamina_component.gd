extends Node
class_name StaminaComponent

signal stamina_changed(current_stamina: float, max_stamina: float)
signal stamina_depleted()
signal stamina_recovered()

@export var max_stamina: float = 100.0
@export var current_stamina: float = 100.0
@export var stamina_drain_rate: float = 30.0  # Потеря в секунду при беге
@export var stamina_regen_rate: float = 0.0  # Восстановление в секунду
@export var regen_delay: float = 1.0  # Задержка перед восстановлением

var is_running: bool = false
var regen_timer: float = 0.0
var is_depleted: bool = false

func _ready():
	current_stamina = max_stamina

func _process(delta: float):
	_update_stamina(delta)

func _update_stamina(delta: float):
	if is_running and current_stamina > 0:
		# Бег - тратим стамину
		regen_timer = regen_delay  # Сбрасываем таймер восстановления
		var drain = stamina_drain_rate * delta
		current_stamina = max(0, current_stamina - drain)
		
		if current_stamina <= 0 and not is_depleted:
			is_depleted = true
			stamina_depleted.emit()
			
	elif current_stamina < max_stamina:
		# Не бежим - восстанавливаем после задержки
		if regen_timer > 0:
			regen_timer -= delta
		else:
			var regen = stamina_regen_rate * delta
			current_stamina = min(max_stamina, current_stamina + regen)
			
			if current_stamina >= max_stamina * 0.3 and is_depleted:
				is_depleted = false
				stamina_recovered.emit()
	
	# Обновляем сигналы
	stamina_changed.emit(current_stamina, max_stamina)

func start_running():
	is_running = true

func stop_running():
	is_running = false

func has_stamina() -> bool:
	return current_stamina > 0 and not is_depleted

func get_stamina_percent() -> float:
	return current_stamina / max_stamina

func use_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func restore_stamina(amount: float):
	current_stamina = min(max_stamina, current_stamina + amount)
	stamina_changed.emit(current_stamina, max_stamina)
