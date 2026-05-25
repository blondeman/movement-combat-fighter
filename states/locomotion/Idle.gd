extends LocomotionState

func enter():
	character.velocity = Vector3.ZERO

func update(delta: float, input: InputPackage):
	process_rotation(delta, Vector3.ZERO)
