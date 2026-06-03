extends SpringArm3D

@export var smooth: float = 20.0
@export var sensitivity: float = 0.003

var target_rotation: Vector3

func _ready() -> void:
	target_rotation = rotation

func _process(delta: float) -> void:
	rotation = rotation.lerp(target_rotation, delta * smooth)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("camera_drag"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_drag"):
		target_rotation.y -= event.relative.x * sensitivity
		target_rotation.x -= event.relative.y * sensitivity
		target_rotation.x = clamp(target_rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_released("camera_drag"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
