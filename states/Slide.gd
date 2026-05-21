extends LocomotionState

@export var slide_speed_threshold: float = 12.0  # should be > normal speed (8.0)
@export var slide_friction: float = 3.0
@export var slide_steer_strength: float = 0.4  # how much player can steer during slide

func default_lifecycle(input: InputPackage) -> String:
	if not character.is_on_floor_or_coyote():
		return "midair"
		
	if input.actions.has("jump"):
		return "jump"
		
	var horizontal_speed = Vector3(character.velocity.x, 0, character.velocity.z).length()
	if horizontal_speed < speed:
		return best_input_that_can_be_paid(input)
		
	return "okay"


func _update(delta: float, input: InputPackage):
	update(delta, input)

func update(delta: float, input: InputPackage):
	process_slide(delta, input)
	character.velocity.y -= gravity * delta
	character.move_and_slide()

func process_slide(delta: float, input: InputPackage):
	var horizontal_vel = Vector3(character.velocity.x, 0, character.velocity.z)
	horizontal_vel = horizontal_vel.lerp(Vector3.ZERO, slide_friction * delta)
	
	var rotated_input = input.get_rotated_input()
	if rotated_input.length_squared() > 0.001:
		var steer_dir = Vector3(rotated_input.x, 0, rotated_input.y).normalized()
		horizontal_vel += steer_dir * slide_steer_strength * horizontal_vel.length() * delta
		if horizontal_vel.length() > horizontal_vel.length():
			horizontal_vel = horizontal_vel.normalized() * horizontal_vel.length()
	
	character.velocity.x = horizontal_vel.x
	character.velocity.z = horizontal_vel.z
