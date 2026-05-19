class_name LocomotionState
extends State

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var tracking_angular_speed : float = 10
@export var speed: float = 8
@export var damping: float = 2

func default_lifecycle(input : InputPackage) -> String:
	if not character.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func _update(delta: float, input: InputPackage):
	process_input_vector(delta, input)
	update(delta, input)


func process_input_vector(delta: float, input: InputPackage):
	var rotated_input: Vector2 = input.get_rotated_input()
	var direction := Vector3(rotated_input.x, 0.0, rotated_input.y).normalized()

	var horizontal_vel := Vector3(character.velocity.x, 0.0, character.velocity.z)

	if rotated_input.length_squared() > 0.001:
		horizontal_vel += direction * speed * delta
		if horizontal_vel.length() > speed:
			horizontal_vel = horizontal_vel.normalized() * speed
	else:
		horizontal_vel = horizontal_vel.lerp(Vector3.ZERO, damping * delta)

	character.velocity.x = horizontal_vel.x
	character.velocity.z = horizontal_vel.z
