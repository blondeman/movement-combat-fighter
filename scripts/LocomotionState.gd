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
	var rotated_input: Vector2 = input.get_rotated_input()
	var direction := Vector3(rotated_input.x, 0.0, rotated_input.y).normalized()
	var has_input := rotated_input.length_squared() > 0.001
	if !character.is_on_floor_or_coyote():
		# Quake-style air acceleration: only accelerate if it would increase speed in wish direction
		if has_input:
			var wish_dir := direction
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
