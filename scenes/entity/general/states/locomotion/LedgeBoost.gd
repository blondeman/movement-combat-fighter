extends LocomotionStateParticles

@export var jump_velocity : float = 15
@export var change_velocity: bool = false

const transition_timing = 0.4
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
	process_jump(input)
	rotate_toward_velocity(delta)
	character.velocity.y -= gravity * delta
	character.move_and_slide()


func exit():
	rotate_toward_velocity(0)


func process_jump(input: InputPackage):
	if works_longer_than(jump_timing) and not jumped:
		var input_direction = input.get_input_direction()
		
		if change_velocity:
			character.velocity = input_direction * speed
		character.velocity.y = jump_velocity
		
		jumped = true
		
		create_particles(character.velocity)
