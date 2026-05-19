extends LocomotionState

@export var speed: float = 5.0

func update(delta: float, input: InputPackage):
	character.velocity.y -= gravity * delta
	character.move_and_slide()
