extends LocomotionState

@export var slide_speed: float = 2

func update(delta: float, input: InputPackage):
	character.status.ledge_slide_time += delta
	apply_air_physics(delta, input)
	character.frame_velocity.y -= gravity * delta
	if character.frame_velocity.y < -slide_speed and character.status.can_slide():
		character.frame_velocity.y = -slide_speed


func default_lifecycle(input : InputPackage):
	if character.is_on_floor_or_coyote():
		var horizontal_speed = Vector3(character.frame_velocity.x, 0, character.frame_velocity.z).length()
		if horizontal_speed > speed:
			return "slide"

		character.status.ledge_slide_time = 0.0
		return best_input_that_can_be_paid(input)
	else:
		if !character.ledge_grab_check():
			return "midair"

		if input.actions.has("dash") and character.status.can_dash():
			character.status.ledge_slide_time = 0.0
			return "dash"

		if input.actions.has("jump"):
			character.status.ledge_slide_time = 0.0
			return "ledge_boost"

		if input.actions.has("light_attack"):
			return "midair_light_attack"

		return "okay"
