extends CharacterBody3D


@export var sensitivity: float = 0.002
@export var debris_hold_offset: Vector3 = Vector3(0, 0.2, -0.5)

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D

var has_debris: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pointer_lock_enter"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("pointer_lock_exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation.y += -event.relative.x * sensitivity
			camera.rotation.x = clampf(
				camera.rotation.x - event.relative.y * sensitivity,
				-PI / 2, PI / 2
			)
		
		if event.is_action_pressed("grab_debris") and not has_debris \
				and ray.is_colliding():
			var debris: Node3D = ray.get_collider()
			var offset: Vector3 = basis * debris_hold_offset
			position = debris.position - offset
			debris.reparent(self)
			debris.position = debris_hold_offset
			has_debris = true
