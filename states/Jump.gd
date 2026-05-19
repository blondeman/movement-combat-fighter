extends LocomotionState

@export var jump_velocity : float = 15

const transition_timing = 0.3
const jump_timing = 0.1

var jumped : bool = false

func default_lifecycle(input : InputPackage) -> String:
	if works_longer_than(transition_timing):
		jumped = false
		if not character.is_on_floor_or_coyote():
			return "midair"
		
		return best_input_that_can_be_paid(input)
	else: 
		return "okay"


func update(delta: float, input : InputPackage):
	process_jump()
	character.velocity.y -= gravity * delta
	character.move_and_slide()


func process_jump():
	if works_longer_than(jump_timing):
		if not jumped:
			character.velocity.y = jump_velocity
			character.coyote_timer = 0.0
			jumped = true
