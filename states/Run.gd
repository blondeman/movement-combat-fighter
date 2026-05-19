extends LocomotionState

@export var speed: float = 5.0

func update(delta: float, input: InputPackage):
	var rotated_input = input.input_direction.rotated(-input.camera_angle)
	var direction: Vector3 = (character.transform.basis * Vector3(rotated_input.x, 0, rotated_input.y)).normalized()
	
	character.velocity.x = direction.x * speed
	character.velocity.z = direction.z * speed
	
	character.move_and_slide()
