extends CharacterBody3D


@export var sensitivity: float
@export var mass: float
@export var debris_throw_impulses: Array[float]
@export var push_curve: Curve

@onready var ray: RayCast3D = $Camera3D/RayCast3D
@onready var debris_hold_pos: Marker3D = $DebrisHoldPos
@onready var back_cam: Camera3D = $SubViewport/BackCamera
@onready var back_cam_subviewport: SubViewport = $SubViewport

var debris: RigidBody3D
var throw_speed_index: int = 0
var back_cam_transform: Transform3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	back_cam_subviewport.world_3d = get_viewport().world_3d
	back_cam_transform = back_cam.transform

func _process(delta: float) -> void:
	var new_transform: Transform3D = transform * back_cam_transform
	back_cam.basis = new_transform.basis
	back_cam.position = new_transform.origin
	
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
			rotation.x = clampf(rotation.x - event.relative.y * sensitivity,
								-PI / 2, PI / 2)
			if debris:
				position = debris.position - basis * debris_hold_pos.position
		
		# Grabbing debris
		if event.is_action_pressed("grab_debris") and not debris \
				and ray.is_colliding():
			debris = ray.get_collider()
			var offset: Vector3 = basis * debris_hold_pos.position
			position = debris.position - offset
			velocity = Vector3.ZERO
			var grab_tween: Tween = create_tween()
			grab_tween.tween_property($Arms, "position:z", 0, 0.1)
		
		# Throwing debris and launching player
		if event.is_action_pressed("throw_debris") and debris:
			debris.freeze = false
			var dir: Vector3 = basis * Vector3.FORWARD
			var impulse: float = debris_throw_impulses[throw_speed_index]
			debris.apply_impulse(impulse * dir)
			debris.apply_torque_impulse(Vector3(
				randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5)
			))
			velocity = impulse / mass * -dir
			debris = null
			var grab_tween: Tween = create_tween()
			grab_tween.tween_property($Arms, "position:z", 1, 0.5) \
				.set_custom_interpolator(push_curve.sample_baked)
		
		# Throw speed
		if event.is_action_pressed("throw_speed_up"):
			throw_speed_index -= 1
		if event.is_action_pressed("throw_speed_down"):
			throw_speed_index += 1
		throw_speed_index = clampi(throw_speed_index, 0, 2)

func get_back_camera_texture() -> ViewportTexture:
	return back_cam_subviewport.get_texture()
