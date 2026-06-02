class_name EntityController
extends CharacterBody3D

@export_group("StateMachine")
@export var input_handler: InputHandler
@export var locomotion: StateMachine
@export var combat: StateMachine
@export var hitbox: Hitbox

@export_group("Movement")
@export var momentum_decay: float = 4.0
@export var air_momentum_decay: float = 1.0
@export var air_acceleration : float = 2.0

@export_group("Cooldowns")
@export var dash_cooldown: float = 1.2
var dash_cooldown_remaining: float = 0.0

@export var coyote_time: float = 0.12
var coyote_timer: float = 0.0
var was_on_floor: bool = false

@export_group("Stairs")
var is_grounded := true
var was_grounded := true
@export var max_step_size := .25

var lock_target: Node3D = null

@export_group("Debug Options")
@export var print_state: bool = false
@export var enabled: bool = true

func _physics_process(delta: float):
	if !enabled:
		return
	
	handle_coyote_time(delta)
	
	was_grounded = is_grounded
	if is_on_floor():
		is_grounded = true
	else:
		is_grounded = false
	
	if input_handler:
		var input = input_handler.get_input()
		stair_step_up(input.get_input_direction())
		locomotion.update(delta, input)
		combat.update(delta, input)
		stair_step_down()
	
	check_world_bounds()


func is_on_floor_or_coyote() -> bool:
	return is_on_floor() or coyote_timer > 0.0


func handle_coyote_time(delta: float):
	if dash_cooldown_remaining > 0:
		dash_cooldown_remaining -= delta
		
	if was_on_floor and not is_on_floor():
		coyote_timer = coyote_time
	elif is_on_floor():
		coyote_timer = 0.0
	if coyote_timer > 0:
		coyote_timer -= delta
	was_on_floor = is_on_floor()


func stair_step_down():
	if is_on_floor():
		return

	if velocity.y <= 0 and was_grounded:
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = self.global_transform
		body_test_params.motion = Vector3(0, -max_step_size, 0)

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			is_grounded = true


func stair_step_up(wish_dir: Vector3):
	if wish_dir == Vector3.ZERO:
		return
	if not is_on_floor() and not was_grounded:
		return

	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()
	var test_transform = global_transform

	body_test_params.from = global_transform
	body_test_params.motion = wish_dir * max_step_size
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return

	# 1. Move to collision point
	var remainder = body_test_result.get_remainder()
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 2. Step up
	body_test_params.from = test_transform
	body_test_params.motion = max_step_size * Vector3.UP
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())
	
	# 3. Forward by remainder
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3.5 Project along wall normal if still blocked
	if body_test_result.get_collision_count() != 0:
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = wish_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (wish_dir - dot_div_mag * wall_normal).normalized()
		body_test_params.from = test_transform
		body_test_params.motion = body_test_result.get_remainder().length() * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

	# 4. Step down onto surface
	body_test_params.from = test_transform
	body_test_params.motion = max_step_size * 2 * Vector3.DOWN
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return

	test_transform = test_transform.translated(body_test_result.get_travel())

	# 5. Reject unwalkable slopes
	var surface_normal = body_test_result.get_collision_normal()
	var surface_angle = snappedf(surface_normal.angle_to(Vector3.UP), 0.001)
	if surface_angle > floor_max_angle:
		return

	# 6. Apply
	var step_up_dist = test_transform.origin.y - global_position.y
	if step_up_dist > 0 and step_up_dist <= max_step_size:
		global_position.y = test_transform.origin.y


func check_world_bounds():
	if global_position.y < -10:
		velocity = Vector3.ZERO
		global_position = Vector3.ZERO
