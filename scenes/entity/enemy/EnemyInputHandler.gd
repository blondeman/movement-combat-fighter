class_name EnemyInputHandler
extends InputHandler


@export_group("Navigation")

@export var nav_agent: NavigationAgent3D
var target: Node3D

@export var link_travel_time: float = 1.0
var link_travel_direction: Vector2 = Vector2.ZERO
var link_timer: float = 0
var do_jump: bool = false

@export_group("Attacking")
@export var attack_range: float = 1.3

@export_group("Dashing")
@export var random_dash_dodge_range: float
@export var random_dash_timer_min: float
@export var random_dash_timer_max: float
var next_dash_timer: float = 0
var dash_angle: Vector2
var dash_input_timer: float = 0 #this is used for the input delay while dashing

func _ready():
	_set_target()
	
	var target_timer := Timer.new()
	add_child(target_timer)
	target_timer.wait_time = 5
	target_timer.timeout.connect(_set_target)
	target_timer.start()
	
	var path_timer := Timer.new()
	add_child(path_timer)
	path_timer.wait_time = 0.2
	path_timer.timeout.connect(_update_path)
	path_timer.start()
	
	nav_agent.link_reached.connect(_jump)


func get_actions(inputPackage: InputPackage):
	inputPackage.actions.append("idle")
	
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - get_parent().global_position)
	var horizontal_direction: Vector2 = Vector2(direction.x, direction.z)
	
	if horizontal_direction.length() <= nav_agent.radius or nav_agent.distance_to_target() < attack_range:
		horizontal_direction = Vector2.ZERO
	
	inputPackage.input_direction = horizontal_direction.normalized()
	if inputPackage.input_direction != Vector2.ZERO:
		inputPackage.actions.append("run")
	
	if _dash():
		inputPackage.actions.append("dash")
		dash_input_timer = 0.1
		var opposite_angle = horizontal_direction.angle() + PI
		var new_angle = opposite_angle + randf_range(-PI / 2, PI / 2)
		dash_angle = Vector2.from_angle(new_angle)
		
	if dash_input_timer > 0 and nav_agent.distance_to_target() < random_dash_dodge_range:
		inputPackage.input_direction = dash_angle
	
	if link_timer > 0:
		if do_jump:
			inputPackage.actions.append("jump")
			do_jump = false
		inputPackage.input_direction = link_travel_direction


func get_combat_actions(inputPackage: InputPackage):
	inputPackage.combat_actions.append("idle")
	
	if nav_agent.distance_to_target() < attack_range:
		inputPackage.combat_actions.append("light_attack")


func _process(delta: float) -> void:
	if link_timer > 0:
		link_timer -= delta
	if next_dash_timer > 0:
		next_dash_timer -= delta
	if dash_input_timer > 0:
		dash_input_timer -= delta


func _dash() -> bool:
	if next_dash_timer <= 0:
		next_dash_timer = randf_range(random_dash_timer_min, random_dash_timer_max)
		return true
	return false


func _jump(details: Dictionary):
	link_timer = link_travel_time
	var link_direction = Vector3(details["link_exit_position"] - details["link_entry_position"])
	link_travel_direction = Vector2(link_direction.x, link_direction.z).normalized()
	if link_direction.y > 0:
		do_jump = true


func _update_path():
	if !target:
		return
	
	nav_agent.target_position = target.global_position


func _set_target():
	if get_tree().get_nodes_in_group("player").size() > 0:
		target = get_tree().get_nodes_in_group("player")[0]
	return
