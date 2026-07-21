extends Control


@onready var throw_speed_panel = $ThrowSpeedPanel

var throw_speed_index: int = 0


func _ready() -> void:
	for child in throw_speed_panel.get_children():
		child.modulate.a = 0.2
	throw_speed_panel.get_child(throw_speed_index).modulate.a = 1

func _input(event: InputEvent) -> void:
	var prev_index: int = throw_speed_index
	if event.is_action_pressed("throw_speed_up") and throw_speed_index > 0:
		throw_speed_index -= 1
	if event.is_action_pressed("throw_speed_down") and throw_speed_index < 2:
		throw_speed_index += 1
	if throw_speed_index != prev_index:
		throw_speed_panel.get_child(prev_index).modulate.a = 0.2
		throw_speed_panel.get_child(throw_speed_index).modulate.a = 1
