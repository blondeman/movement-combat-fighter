class_name LocomotionState
extends State

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var tracking_angular_speed : float = 10
@export var speed: float = 8
@export var damping: float = 2

func default_lifecycle(input : InputPackage) -> String:
	if not character.is_on_floor_or_coyote():
		return "midair"

	if not character.status.can_dash():
		input.actions.erase("dash")
		input.actions.erase("jump_dash")

	return best_input_that_can_be_paid(input)


func apply_air_physics(delta: float, input: InputPackage) -> void:
	var input_direction := input.get_input_direction()
	if input_direction.length_squared() > 0.001:
		_air_accelerate(input_direction, delta)
		_air_control(input_direction, delta)
	else:
		decay_horizontal_velocity(character.air_momentum_decay, delta)


func process_rotation(delta: float, input_direction: Vector3):
	if character.lock_target:
		rotate_toward_lock_target(delta)
	else:
		rotate_toward_direction(delta, input_direction)


func rotate_toward_lock_target(delta: float = 0.0):
	var to_target = character.lock_target.global_position - character.global_position
	to_target.y = 0.0
	
	if to_target.length_squared() < 0.001:
		return
	
	var face_direction = character.basis.z
	var angle = face_direction.signed_angle_to(to_target.normalized(), Vector3.UP)
	
	if delta > 0.0 and abs(angle) >= tracking_angular_speed * delta:
		character.rotate_y(sign(angle) * tracking_angular_speed * delta)
	else:
		character.rotate_y(angle)


func rotate_toward_direction(delta: float, input_direction: Vector3) -> float:
	var face_direction = character.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if delta > 0.0 and abs(angle) >= tracking_angular_speed * delta:
		character.rotate_y(sign(angle) * tracking_angular_speed * delta)
		return sign(angle) * tracking_angular_speed * delta
	else:
		character.rotate_y(angle)
		return angle


func rotate_toward_velocity(delta: float):
	var target_direction := Vector3(character.frame_velocity.x, 0, character.frame_velocity.z).normalized()
	rotate_toward_direction(delta, target_direction)


func decay_horizontal_velocity(decay: float, delta: float) -> void:
	var horizontal := Vector3(character.frame_velocity.x, 0.0, character.frame_velocity.z)
	var horizontal_speed := horizontal.length()
	var new_speed := move_toward(horizontal_speed, 0.0, decay * delta)
	if horizontal_speed > 0.0:
		horizontal = (horizontal / horizontal_speed) * new_speed
	character.frame_velocity.x = horizontal.x
	character.frame_velocity.z = horizontal.z


func _air_accelerate(wish_dir: Vector3, delta: float) -> void:
	var accel: float = character.air_stop_speed if character.frame_velocity.dot(wish_dir) < 0 else character.air_acceleration

	var current_speed := character.frame_velocity.dot(wish_dir)
	var add_speed := speed - current_speed
	if add_speed <= 0.0:
		return

	var accel_speed: float = accel * delta * speed
	accel_speed = min(accel_speed, add_speed)
	character.frame_velocity.x += wish_dir.x * accel_speed
	character.frame_velocity.y += wish_dir.y * accel_speed
	character.frame_velocity.z += wish_dir.z * accel_speed


func _air_control(wish_dir: Vector3, delta: float) -> void:
	if wish_dir.z == 0.0:
		return

	var original_y: float = character.frame_velocity.y
	character.frame_velocity.y = 0.0
	var air_speed: float = character.frame_velocity.length()
	var vel_norm: Vector3 = character.frame_velocity.normalized()

	var dot: float = vel_norm.dot(wish_dir)
	if dot > 0.0:
		var k: float = character.air_control * dot * dot * delta
		vel_norm.x = vel_norm.x * air_speed + wish_dir.x * k
		vel_norm.y = vel_norm.y * air_speed + wish_dir.y * k
		vel_norm.z = vel_norm.z * air_speed + wish_dir.z * k
		vel_norm = vel_norm.normalized()

	character.frame_velocity.x = vel_norm.x * air_speed
	character.frame_velocity.y = original_y
	character.frame_velocity.z = vel_norm.z * air_speed
