extends LocomotionState

@export var dash_velocity : float = 30
@export var dash_gravity_scale: float = 0.2

const transition_timing = 0.2
const dash_timing = 0.1

var dashed : bool = false
var dash_direction: Vector3 = Vector3.ZERO

func default_lifecycle(input: InputPackage) -> String:
	if works_longer_than(transition_timing):
		dashed = false
		dash_direction = Vector3.ZERO
		if not character.is_on_floor():
			return "midair"
			
		var horizontal_speed = Vector3(character.velocity.x, 0, character.velocity.z).length()
		if horizontal_speed > speed:
			return "slide"
		
		return best_input_that_can_be_paid(input)
	else:
		return "okay"


func update(delta: float, input: InputPackage):
	process_dash(input)
	character.move_and_slide()


func process_dash(input: InputPackage):
	if works_longer_than(dash_timing) and not dashed:
		var input_direction := input.get_input_direction()

		if input_direction.length_squared() > 0.001:
			dash_direction = input_direction * dash_velocity
		else:
			dash_direction = character.global_transform.basis.z * dash_velocity

		character.velocity.x = dash_direction.x
		character.velocity.z = dash_direction.z
		character.velocity.y = 0

		if character.is_on_floor():
			rotate_toward_direction(input_direction, 0.0)

		character.dash_cooldown_remaining = character.dash_cooldown
		dashed = true
