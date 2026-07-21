extends Node3D


func _process(delta: float) -> void:
	$UI.set_back_camera_texture($Player.get_back_camera_texture())
