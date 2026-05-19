extends LocomotionState

@export var dash_velocity : float = 30
@export var dash_gravity_scale: float = 0.2

const transition_timing = 0.2
const dash_timing = 0.0

var dashed : bool = false
var dash_direction: Vector3 = Vector3.ZERO

func default_lifecycle(input: InputPackage) -> String:
	if works_longer_than(transition_timing):
		dashed = false
		dash_direction = Vector3.ZERO
		if not character.is_on_floor():
			return "midair"
		# Dash exits into slide if still moving fast
		var horizontal_speed = Vector3(character.velocity.x, 0, character.velocity.z).length()
		if horizontal_speed > speed:
			return "slide"
		return best_input_that_can_be_paid(input)
	else:
		return "okay"


func update(delta: float, input: InputPackage):
	process_dash(input)
	if dashed and dash_direction != Vector3.ZERO:
		character.velocity.x = dash_direction.x
		character.velocity.z = dash_direction.z
	character.velocity.y -= gravity * dash_gravity_scale * delta
	character.move_and_slide()


func process_dash(input: InputPackage):
	if works_longer_than(dash_timing) and not dashed:
		var rotated_input = input.get_rotated_input()
		var input_direction = Vector3(rotated_input.x, 0, rotated_input.y)
		if rotated_input.length_squared() > 0.001:
			dash_direction = input_direction * dash_velocity
		else:
			dash_direction = character.global_transform.basis.z * dash_velocity
		character.velocity.x = dash_direction.x
		character.velocity.z = dash_direction.z
		character.velocity.y = 0
		character.momentum = Vector3(dash_direction.x, 0, dash_direction.z)
		
		if character.is_on_floor():
			var face_direction = character.basis.z
			var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
			character.rotate_y(angle)
		
		character.dash_cooldown_remaining = character.dash_cooldown
		dashed = true
