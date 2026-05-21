extends LocomotionState

@export var jump_velocity : float = 15
@export var dash_velocity : float = 30
@export var dash_gravity_scale: float = 0.2

const transition_timing = 0.3  
const dash_jump_timing = 0.1

var dash_jumped : bool = false
var dash_direction: Vector3 = Vector3.ZERO

func default_lifecycle(input : InputPackage) -> String:
	if works_longer_than(transition_timing):
		dash_jumped = false
		if not character.is_on_floor_or_coyote():
			return "midair"
		
		return best_input_that_can_be_paid(input)
	else: 
		return "okay"


func update(delta: float, input : InputPackage):
	process_dash_jump(input)
	if dash_jumped and dash_direction != Vector3.ZERO:
		character.velocity.x = dash_direction.x
		character.velocity.z = dash_direction.z
	character.velocity.y -= gravity * dash_gravity_scale * delta
	character.move_and_slide()


func process_dash_jump(input: InputPackage):
	if works_longer_than(dash_jump_timing) and not dash_jumped:
		var rotated_input = input.get_rotated_input()
		var input_direction = Vector3(rotated_input.x, 0, rotated_input.y)
		if rotated_input.length_squared() > 0.001:
			dash_direction = input_direction * dash_velocity
		else:
			dash_direction = character.global_transform.basis.z * dash_velocity
		character.velocity.x = dash_direction.x
		character.velocity.z = dash_direction.z
		character.velocity.y = jump_velocity
		
		character.dash_cooldown_remaining = character.dash_cooldown
		character.coyote_timer = 0.0
		dash_jumped = true
