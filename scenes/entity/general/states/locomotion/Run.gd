extends LocomotionState

@export var turn_speed: float = 2.0

@export var accel: float = 10.0       # Ground acceleration (Quake default ~10)
@export var friction: float = 6.0     # Ground friction (Quake default ~6)
@export var stop_speed: float = 1.5

func update(delta: float, input: InputPackage):
	process_input_vector(delta, input)
	character.move_and_slide()

func process_input_vector(delta: float, input: InputPackage):
	var input_direction := input.get_input_direction()
	var face_direction := character.basis.z

	process_rotation(delta, input_direction)

	# Quake-style ground movement
	var wish_dir: Vector3
	if not character.lock_target and abs(face_direction.signed_angle_to(input_direction, Vector3.UP)) >= tracking_angular_speed * delta:
		wish_dir = input_direction
	else:
		wish_dir = face_direction.rotated(Vector3.UP, face_direction.signed_angle_to(input_direction, Vector3.UP))

	var wish_speed := speed if wish_dir.length_squared() > 0.0 else 0.0

	# Apply friction/stopspeed first
	_apply_friction(delta, wish_speed)

	# Then accelerate toward wish_dir
	_apply_acceleration(delta, wish_dir, wish_speed)


func _apply_friction(delta: float, wish_speed: float) -> void:
	var vel := character.velocity
	var current_speed: float = vel.length()
	if current_speed < 0.001:
		return

	# Drop speed: if moving slower than stop_speed, treat current as stop_speed
	# so friction doesn't become negligibly small at low speeds
	var control: float = max(current_speed, stop_speed)
	var drop := control * friction * delta
	var new_speed: float = max(current_speed - drop, 0.0) / current_speed
	character.velocity = vel * new_speed


func _apply_acceleration(delta: float, wish_dir: Vector3, wish_speed: float) -> void:
	# How much of wish_dir we're already moving in
	var current_speed := character.velocity.dot(wish_dir)
	# Only add velocity up to the cap
	var add_speed := wish_speed - current_speed
	if add_speed <= 0.0:
		return

	var accel_speed: float = min(accel * wish_speed * delta, add_speed)
	character.velocity += wish_dir * accel_speed
