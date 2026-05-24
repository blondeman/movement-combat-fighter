extends LocomotionState

@export var turn_speed: float = 2.0

func update(delta: float, input: InputPackage):
	process_input_vector(delta, input)
	character.move_and_slide()

func process_input_vector(delta: float, input: InputPackage):
	var input_direction := input.get_input_direction()
	var face_direction = character.basis.z
	var applied_angle = rotate_toward_direction(input_direction, delta)
	
	if abs(applied_angle) >= tracking_angular_speed * delta:
		character.velocity = face_direction.rotated(Vector3.UP, applied_angle) * turn_speed
	else:
		character.velocity = face_direction.rotated(Vector3.UP, applied_angle) * speed
