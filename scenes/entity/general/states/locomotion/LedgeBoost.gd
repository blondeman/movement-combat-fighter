extends LocomotionStateParticles

@export var jump_velocity: float = 15
@export var wall_boost: float = 10.0

const transition_timing = 0.4
const jump_timing = 0.1

var jumped: bool = false


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
	character.frame_velocity.y -= gravity * delta


func exit():
	rotate_toward_velocity(0)


func process_jump(input: InputPackage):
	if works_longer_than(jump_timing) and not jumped:
		var input_direction := input.get_input_direction()
		var has_input := input_direction.length_squared() > 0.001

		if has_input:
			var flat_velocity := Vector3(character.frame_velocity.x, 0.0, character.frame_velocity.z)
			var current_speed := flat_velocity.length()

			if current_speed > speed:
				var dot := flat_velocity.normalized().dot(input_direction)
				var retained_speed := lerpf(speed, current_speed, (dot + 1.0) * 0.5)
				var blended_dir := (flat_velocity.normalized() + input_direction * (1.0 - dot)).normalized()
				character.frame_velocity.x = blended_dir.x * retained_speed
				character.frame_velocity.z = blended_dir.z * retained_speed
			else:
				character.frame_velocity.x = input_direction.x * speed
				character.frame_velocity.z = input_direction.z * speed

		character.frame_velocity.y = jump_velocity

		var wall_normal := character.status.ledge_wall_normal
		var boost_dir := Vector3(wall_normal.x, 0.0, wall_normal.z).normalized()
		var approach_speed := absf(character.frame_velocity.dot(boost_dir))
		character.frame_velocity.x += boost_dir.x * maxf(approach_speed, wall_boost)
		character.frame_velocity.z += boost_dir.z * maxf(approach_speed, wall_boost)

		jumped = true
		create_particles(character.frame_velocity)
