class_name LocomotionState
extends State

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var tracking_angular_speed : float = 10
@export var speed: float = 8
@export var damping: float = 2

func default_lifecycle(input : InputPackage) -> String:
	if not character.is_on_floor_or_coyote():
		return "midair"
	
	if character.dash_cooldown_remaining > 0:
		input.actions.erase("dash")
		input.actions.erase("jump_dash")
	
	return best_input_that_can_be_paid(input)


func _update(delta: float, input: InputPackage):
	process_input_vector(delta, input)
	update(delta, input)


func process_input_vector(delta: float, input: InputPackage):
	var rotated_input: Vector2 = input.get_rotated_input()
	var direction := Vector3(rotated_input.x, 0.0, rotated_input.y).normalized()
	var has_input := rotated_input.length_squared() > 0.001

	if character.is_on_floor_or_coyote():
		character.momentum = character.momentum.lerp(Vector3.ZERO, character.momentum_decay * delta)
	else:
		character.momentum = character.momentum.lerp(Vector3.ZERO, character.air_momentum_decay * delta)

	if has_input:
		var target: Vector3 = direction * speed
		var blended: Vector3 = character.momentum + target
		var momentum_speed: float = character.momentum.length()
		var max_speed: float = max(speed, momentum_speed)
		if blended.length() > max_speed:
			blended = blended.normalized() * max_speed
		character.velocity.x = blended.x
		character.velocity.z = blended.z
	else:
		character.velocity.x = character.momentum.x
		character.velocity.z = character.momentum.z
