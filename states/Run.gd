extends LocomotionState

@export var turn_speed: float = 2.0

func update(delta: float, input: InputPackage):
	process_input_vector(delta, input)
	character.move_and_slide()

func process_input_vector(delta: float, input: InputPackage):
	var rotated_input = input.get_rotated_input()
	var input_direction = Vector3(rotated_input.x, 0, rotated_input.y)
	var face_direction = character.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= tracking_angular_speed * delta:
		character.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * turn_speed
		character.rotate_y(sign(angle) * tracking_angular_speed * delta)
	else:
		character.velocity = face_direction.rotated(Vector3.UP, angle) * speed
		character.rotate_y(angle)
