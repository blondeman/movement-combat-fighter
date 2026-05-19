extends SpringArm3D

@export_group("Scene Variables")
@export var camera: Camera3D

@export_category("Camera Settings")
@export var sensitivity_x: float = 3
@export var sensitivity_y: float = 3
@export var look_lerp_speed: float = 5.0
@export var min_pitch: float = -60.0
@export var max_pitch: float = 60.0

var _target_camera_rotation: Vector3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	if !camera:
		return
	
	camera.rotation.x = lerp_angle(camera.rotation.x, _target_camera_rotation.x, clamp(look_lerp_speed * delta, 0.0, 1.0))
	camera.rotation.y = lerp_angle(camera.rotation.y, _target_camera_rotation.y, clamp(look_lerp_speed * delta, 0.0, 1.0))
	camera.rotation.z = lerp_angle(camera.rotation.z, _target_camera_rotation.z, clamp(look_lerp_speed * delta, 0.0, 1.0))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity_x * 0.001)
		rotation.x -= event.relative.y * sensitivity_y * 0.001
		rotation.x = clamp(rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
