extends CharacterBody3D


@export var sensitivity: float
@export var debris_hold_offset: Vector3
@export var debris_throw_impulse: float
@export var mass: float

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D

var debris: RigidBody3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pointer_lock_enter"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("pointer_lock_exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Turning the camera
		if event is InputEventMouseMotion:
			rotation.y += -event.relative.x * sensitivity
			rotation.x = clampf(
				rotation.x - event.relative.y * sensitivity, -PI / 2, PI / 2)
			if debris:
				position = debris.position - basis * debris_hold_offset
		
		# Grabbing debris (aka tungsten cube)
		if event.is_action_pressed("grab_debris") and not debris and ray.is_colliding():
			debris = ray.get_collider()
			var offset: Vector3 = basis * debris_hold_offset
			position = debris.position - offset
			velocity = Vector3.ZERO
		
		# Throwing debris and launching player at 5 billion mph
		if event.is_action_pressed("throw_debris") and debris:
			debris.freeze = false
			var dir: Vector3 = basis * Vector3.FORWARD
			debris.apply_impulse(debris_throw_impulse * dir)
			debris.apply_torque_impulse(Vector3(randf_range(-5, 5),randf_range(-5, 5),randf_range(-5, 5)))
			velocity = debris_throw_impulse / mass * -dir
			debris = null
