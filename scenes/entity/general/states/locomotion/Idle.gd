extends LocomotionState

func enter():
	character.frame_velocity = Vector3.ZERO


func update(delta: float, input: InputPackage):
	decay_horizontal_velocity(character.momentum_decay, delta)
	process_rotation(delta, Vector3.ZERO)
