extends CharacterBody3D


@export var sensitivity: float = 0.002

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if ray.is_colliding():
		print("raycast collision")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pointer_lock_enter"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("pointer_lock_exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion \
	and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.y += -event.relative.x * sensitivity
		camera.rotation.x = clampf(
			camera.rotation.x - event.relative.y * sensitivity,
			-PI / 2, PI / 2
		)
