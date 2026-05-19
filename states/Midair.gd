extends LocomotionState

func update(delta: float, input: InputPackage):
	character.velocity.y -= gravity * delta
	character.move_and_slide()


func default_lifecycle(input : InputPackage):
	if character.is_on_floor():
		return best_input_that_can_be_paid(input)
	else:
		if input.actions.has("dash"):
			return "dash"
		return "okay"
