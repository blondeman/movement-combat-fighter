class_name EntityController
extends CharacterBody3D

const DIRECTION_FORWARD_RIGHT := Vector3(0.707106,0,0.707106)
const DIRECTION_FORWARD_LEFT := Vector3(0.707106,0,-0.707106)
const DIRECTION_BACKWARD_RIGHT := Vector3(-0.707106,0,0.707106)
const DIRECTION_BACKWARD_LEFT := Vector3(-0.707106,0,-0.707106)

@export_group("StateMachine")
@export var input_handler: InputHandler
@export var locomotion: StateMachine
@export var combat: StateMachine
@export var health: Health
@export var hitbox: Hitbox

@export_group("Movement")
@export var momentum_decay: float = 4.0
@export var air_momentum_decay: float = 1.0
@export var air_acceleration : float = 2.0
@export var air_stop_speed : float = 2.0
@export var air_control: float = 2.0

@export_group("Cooldowns")
@export var dash_cooldown: float = 1.2
var dash_cooldown_remaining: float = 0.0

@export var coyote_time: float = 0.12
var coyote_timer: float = 0.0
var was_on_floor: bool = false

@export_group("Stairs")
var is_grounded := true
var was_grounded := true
@export var max_step_size: float = .25

@export_group("Ledge Grab")
@export var max_ledge_grab_height: float = 1.5
@export var ledge_grab_reach: float = 0.5
@export var ledge_layer: int = 6

var lock_target: Node3D = null

@export_group("Debug Options")
@export var print_state: bool = false
@export var enabled: bool = true
@export var god_mode: bool = false

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


# Returns a dict with:
#   "hit"            : bool   — whether a valid surface was found ahead+above
#   "step_height"    : float  — how far up the landing point is from current position
#   "surface_normal" : Vector3
#   "land_transform" : Transform3D — where the body would end up
# Returns null if no forward collision (nothing to step up onto / grab)
func _probe_ledge_or_step(wish_dir: Vector3, check_dist: float, horizontal_reach: float = 0.0) -> Variant:
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()
	var test_transform = global_transform

	# 1. Forward probe — must hit something
	body_test_params.from = test_transform
	body_test_params.motion = wish_dir * (max_step_size + horizontal_reach)
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return null
	var remainder = body_test_result.get_remainder()
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 2. Step up by check_dist
	body_test_params.from = test_transform
	body_test_params.motion = check_dist * Vector3.UP
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

	# 4. Step down onto surface — must land on something
	body_test_params.from = test_transform
	body_test_params.motion = check_dist * 2 * Vector3.DOWN
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return null
	test_transform = test_transform.translated(body_test_result.get_travel())

	return {
		"hit": true,
		"step_height": test_transform.origin.y - global_position.y,
		"surface_normal": body_test_result.get_collision_normal(),
		"land_transform": test_transform,
	}


func stair_step_up(wish_dir: Vector3) -> void:
	if wish_dir == Vector3.ZERO:
		return
	if not is_on_floor() and not was_grounded:
		return
	var probe = _probe_ledge_or_step(wish_dir, max_step_size)
	if probe == null:
		return
	var surface_angle = snappedf(probe.surface_normal.angle_to(Vector3.UP), 0.001)
	if surface_angle > floor_max_angle:
		return
	var step_height: float = probe.step_height
	if step_height > 0.0 and step_height <= max_step_size:
		global_position.y = probe.land_transform.origin.y


func ledge_grab_check() -> bool:
	if is_on_floor():
		return false
	var walls = check_surrounding_walls(collision_mask | (1 << (ledge_layer - 1)))
	for wall in walls:
		if wall.layer & (1 << (ledge_layer - 1)):
			return true
		
		var probe = _probe_ledge_or_step(wall.direction, max_ledge_grab_height, ledge_grab_reach)
		if probe == null:
			continue
		var step_height: float = probe.step_height
		if step_height <= max_step_size:
			continue
		if step_height > max_ledge_grab_height:
			continue
		var surface_angle = snappedf(probe.surface_normal.angle_to(Vector3.UP), 0.001)
		if surface_angle > floor_max_angle:
			continue
		return true
	return false


func check_surrounding_walls(mask: int = collision_mask) -> Array:
	var space_state = get_world_3d().direct_space_state
	var results = []
	
	var directions = [
		Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT, 
		DIRECTION_FORWARD_RIGHT, DIRECTION_FORWARD_LEFT, DIRECTION_BACKWARD_RIGHT, DIRECTION_BACKWARD_LEFT]
	
	for dir in directions:
		var query = PhysicsRayQueryParameters3D.create(
			global_position,
			global_position + dir * (max_step_size + ledge_grab_reach),
			mask
		)
		var result = space_state.intersect_ray(query)
		if result:
			results.append({
				"direction": dir,
				"normal": result.normal,
				"distance": global_position.distance_to(result.position),
				"layer": result.collider.collision_layer,
			})
	return results


func check_world_bounds():
	if global_position.y < -10:
		velocity = Vector3.ZERO
		global_position = Vector3.ZERO
