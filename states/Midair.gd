extends LocomotionState

func update(delta: float, input: InputPackage):
	character.velocity.y -= gravity * delta
	character.move_and_slide()


func default_lifecycle(input : InputPackage):
	if character.is_on_floor_or_coyote():
		return best_input_that_can_be_paid(input)
	else:
		if input.actions.has("dash") and character.dash_cooldown_remaining <= 0:
			return "dash"
		return "okay"
