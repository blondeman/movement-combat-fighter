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
@export var status: CharacterStatus

@export_group("Movement")
@export var momentum_decay: float = 10.0
@export var air_momentum_decay: float = 1.0
@export var air_acceleration : float = 2.0
@export var air_stop_speed : float = 2.0
@export var air_control: float = 2.0

@export_group("Stairs")
var is_grounded := true
var was_grounded := true
@export var max_step_size: float = .25

@export_group("Ledge Grab")
@export var ledge_grab_reach: float = 0.5
@export var max_wall_jump_angle: float = 80

var lock_target: Node3D = null

@export_group("Debug Options")
@export var print_state: bool = false
@export var enabled: bool = true
@export var god_mode: bool = false

var frame_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float):
	if !enabled:
		return

	status.tick(delta, is_on_floor())
	was_grounded = is_grounded
	is_grounded = is_on_floor()

	if input_handler:
		var input = input_handler.get_input()
		stair_step_up(input.get_input_direction())
		
		locomotion.update(delta, input)
		combat.update(delta, input)
	
	velocity = frame_velocity
	move_and_slide()
	frame_velocity = velocity
	
	stair_step_down()
	
	check_world_bounds()


func is_on_floor_or_coyote() -> bool:
	return status.is_on_floor_or_coyote(is_on_floor())


func stair_step_down():
	if is_on_floor():
		return

	if frame_velocity.y <= 0 and was_grounded:
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = self.global_transform
		body_test_params.motion = Vector3(0, -max_step_size, 0)

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			is_grounded = true


func _probe_step(wish_dir: Vector3, check_dist: float) -> Variant:
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()
	var test_transform = global_transform

	body_test_params.from = test_transform
	body_test_params.motion = wish_dir * .5
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return null
	var remainder = body_test_result.get_remainder()
	test_transform = test_transform.translated(body_test_result.get_travel())

	body_test_params.from = test_transform
	body_test_params.motion = check_dist * Vector3.UP
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	if body_test_result.get_collision_count() != 0:
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = wish_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (wish_dir - dot_div_mag * wall_normal).normalized()
		body_test_params.from = test_transform
		body_test_params.motion = body_test_result.get_remainder().length() * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

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
	var probe = _probe_step(wish_dir, max_step_size)
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
	var walls = check_surrounding_walls(collision_mask)
	for wall in walls:
		var angle := rad_to_deg(wall.normal.angle_to(up_direction))
		if angle >= max_wall_jump_angle:
			status.ledge_wall_normal = wall.normal
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
			global_position + dir * (ledge_grab_reach),
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
		frame_velocity = Vector3.ZERO
		global_position = Vector3.ZERO


func add_force(force: Vector3) -> void:
	frame_velocity += force
