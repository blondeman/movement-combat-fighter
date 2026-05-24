extends LocomotionState

func enter():
	character.velocity = Vector3.ZERO

func update(delta: float, input: InputPackage):
	process_rotation(Vector3.ZERO, delta)
