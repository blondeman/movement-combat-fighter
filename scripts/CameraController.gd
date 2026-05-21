extends SpringArm3D

@export_group("Scene Variables")
@export var character: EntityController
@export var camera: Camera3D
@export var marker: Node3D

@export_category("Camera Settings")
@export var sensitivity_x: float = 3
@export var sensitivity_y: float = 3
@export var look_lerp_speed: float = 5.0
@export var min_pitch: float = -60.0
@export var max_pitch: float = 60.0
@export var desired_pitch: float = 0.0
@export var pitch_lift: float = 10
@export var swap_threshold: float = 0.05
@export var swap_cooldown: float = 0.3

var _swap_cooldown_timer: float = 0.0
var _target_camera_rotation: Vector3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	top_level = true
	set_lock_target(null)


func _process(delta: float) -> void:
	global_position = get_parent().global_position
	
	if !camera:
		return
	
	if character.lock_target:
		_look_at_target(delta)
		_set_marker_position()
	
	camera.rotation.x = lerp_angle(camera.rotation.x, _target_camera_rotation.x, clamp(look_lerp_speed * delta, 0.0, 1.0))
	camera.rotation.y = lerp_angle(camera.rotation.y, _target_camera_rotation.y, clamp(look_lerp_speed * delta, 0.0, 1.0))
	camera.rotation.z = lerp_angle(camera.rotation.z, _target_camera_rotation.z, clamp(look_lerp_speed * delta, 0.0, 1.0))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var screen_width: float = get_viewport().get_visible_rect().size.x
		if character.lock_target and event.relative.length() >= swap_threshold * screen_width:
			_switch_lock_target(event.relative)
			return
		
		if !character.lock_target:
			rotate_y(-event.relative.x * sensitivity_x * 0.001)
			rotation.x -= event.relative.y * sensitivity_y * 0.001
			rotation.x = clamp(rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event.is_action_pressed("target_lock"):
		if character.lock_target:
			clear_lock_target()
		else:
			set_lock_target(get_lock_target())


func _set_marker_position():
	marker.global_position = character.lock_target.global_position


func _look_at_target(delta: float) -> void:
	var desired_dir: Vector3 = (character.lock_target.global_position - global_position).normalized()
	if desired_dir.length_squared() < 0.001:
		return

	rotation.x = lerp_angle(rotation.x, deg_to_rad(desired_pitch), clamp(look_lerp_speed * delta, 0.0, 1.0))

	var desired_yaw: float = atan2(-desired_dir.x, -desired_dir.z)
	rotation.y = lerp_angle(rotation.y, desired_yaw, clamp(look_lerp_speed * delta, 0.0, 1.0))

	var cam_dir: Vector3 = (character.lock_target.global_position - camera.global_position).normalized()
	var local_dir: Vector3 = camera.global_basis.inverse() * cam_dir
	_target_camera_rotation.x = asin(local_dir.y)
	_target_camera_rotation.y = 0.0


func set_lock_target(_target: Node3D):
	character.lock_target = _target
	if _target == null:
		_target_camera_rotation = Vector3(deg_to_rad(pitch_lift), 0.0, 0.0)
		marker.visible = false
	else:
		marker.visible = true


func clear_lock_target():
	set_lock_target(null)


func _get_best_target(origin_screen_pos: Vector2, direction: Vector2 = Vector2.ZERO, exclude: Node3D = null) -> Node3D:
	var best_target: Node3D = null
	var best_score: float = INF

	for t in get_tree().get_nodes_in_group("target"):
		if t is not Node3D or t == exclude:
			continue
		if not camera.is_position_in_frustum(t.global_position):
			continue

		var screen_pos: Vector2 = camera.unproject_position(t.global_position)
		var to_target: Vector2 = screen_pos - origin_screen_pos

		# If a direction is given, filter to targets in that direction
		if direction != Vector2.ZERO and to_target.dot(direction) <= 0.0:
			continue

		var score: float = to_target.length()
		if score < best_score:
			best_score = score
			best_target = t

	return best_target


func get_lock_target() -> Node3D:
	var screen_center: Vector2 = get_viewport().get_visible_rect().size / 2.0
	return _get_best_target(screen_center)


func _switch_lock_target(mouse_delta: Vector2) -> void:
	if _swap_cooldown_timer > 0.0:
		return
	
	var current_screen_pos: Vector2 = camera.unproject_position(character.lock_target.global_position)
	var best: Node3D = _get_best_target(current_screen_pos, mouse_delta, character.lock_target)
	if best:
		set_lock_target(best)
		_swap_cooldown_timer = swap_cooldown
