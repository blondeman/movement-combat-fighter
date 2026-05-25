extends CombatState

func update(delta: float, input: InputPackage):
	process_attack(input)
	process_rotation(delta, input.get_input_direction())
	character.velocity.y -= gravity * delta
	character.move_and_slide()

func default_lifecycle(input: InputPackage) -> String:
	if works_longer_than(animation_length):
		attacked = false
		
		if character.is_on_floor_or_coyote():
			return "idle"
		else:
			return "midair"
		
	else:
		return "okay"
