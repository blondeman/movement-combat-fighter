class_name LocomotionState
extends State

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var tracking_angular_speed : float = 10
@export var speed: float = 8
@export var damping: float = 2

func default_lifecycle(input : InputPackage) -> String:
	if not character.is_on_floor_or_coyote():
		return "midair"
	
	if character.dash_cooldown_remaining > 0:
		input.actions.erase("dash")
		input.actions.erase("jump_dash")
	
	return best_input_that_can_be_paid(input)


func _update(delta: float, input: InputPackage):
	process_input_vector(delta, input)
	update(delta, input)


func process_input_vector(delta: float, input: InputPackage):
	var input_direction := input.get_input_direction()
	var has_input := input_direction.length_squared() > 0.001
	if !character.is_on_floor_or_coyote():
		if has_input:
			var wish_dir: Vector3 = input_direction
			var current_speed := Vector3(character.velocity.x, 0.0, character.velocity.z).dot(wish_dir)
			var add_speed := speed - current_speed
			if add_speed > 0.0:
				var accel_speed: float = character.air_acceleration * speed * delta
				accel_speed = min(accel_speed, add_speed)
				character.velocity.x += wish_dir.x * accel_speed
				character.velocity.z += wish_dir.z * accel_speed
		else:
			character.velocity.x = move_toward(character.velocity.x, 0.0, character.air_momentum_decay * delta)
			character.velocity.z = move_toward(character.velocity.z, 0.0, character.air_momentum_decay * delta)


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
	var target_direction := Vector3(character.velocity.x, 0, character.velocity.z).normalized()
	rotate_toward_direction(delta, target_direction)
