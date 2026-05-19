extends LocomotionState

@export var jump_velocity : float = 20
@export var dash_velocity : float = 30

const transition_timing = 0.1  
const dash_jump_timing = 0.1

var dash_jumped : bool = false

func default_lifecycle(input : InputPackage) -> String:
	if works_longer_than(transition_timing):
		dash_jumped = false
		if not character.is_on_floor():
			return "midair"
		
		return best_input_that_can_be_paid(input)
	else: 
		return "okay"


func update(delta: float, input : InputPackage):
	process_dash_jump(input)
	character.velocity.y -= gravity * delta
	character.move_and_slide()


func process_dash_jump(input: InputPackage):
	if works_longer_than(dash_jump_timing):
		if not dash_jumped:
			var rotated_input = input.get_rotated_input()
			character.velocity.x = rotated_input.x * dash_velocity
			character.velocity.z = rotated_input.y * dash_velocity
			character.velocity.y = jump_velocity
			dash_jumped = true
