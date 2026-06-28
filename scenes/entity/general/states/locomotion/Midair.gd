extends LocomotionState


func update(delta: float, input: InputPackage):
	apply_air_physics(delta, input)
	character.frame_velocity.y -= gravity * delta


func default_lifecycle(input : InputPackage):
	if character.is_on_floor_or_coyote():
		var horizontal_speed = Vector3(character.frame_velocity.x, 0, character.frame_velocity.z).length()
		if horizontal_speed > speed:
			return "slide"
		
		character.status.ledge_slide_time = 0.0
		return best_input_that_can_be_paid(input)
	else:
		if input.actions.has("dash") and character.status.can_dash():
			character.status.ledge_slide_time = 0.0
			return "dash"
		
		if character.ledge_grab_check():
			return "ledge_slide"
		
		if input.actions.has("light_attack"):
			return "midair_light_attack"
		
		return "okay"
