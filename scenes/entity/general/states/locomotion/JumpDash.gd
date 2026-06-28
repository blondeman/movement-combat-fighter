extends LocomotionStateParticles

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


func process_dash_jump(input: InputPackage):
	if works_longer_than(dash_jump_timing) and not dash_jumped:
		var input_direction = input.get_input_direction()
		rotate_toward_direction(0, input_direction)
		
		if input_direction.length_squared() > 0.001:
			dash_direction = input_direction * dash_velocity
		else:
			dash_direction = character.global_transform.basis.z * dash_velocity
		character.frame_velocity.x = dash_direction.x
		character.frame_velocity.z = dash_direction.z
		character.frame_velocity.y = jump_velocity
		
		character.status.start_dash_cooldown()
		character.status.consume_coyote()
		dash_jumped = true
		
		create_particles(character.frame_velocity)
