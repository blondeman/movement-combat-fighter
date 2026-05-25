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

func get_input() -> InputPackage:
	var new_input = InputPackage.new()
	
	new_input.actions.append("idle")
	
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - get_parent().global_position)
	new_input.input_direction = Vector2(direction.x, direction.z).normalized()
	if new_input.input_direction != Vector2.ZERO:
		new_input.actions.append("run")
	
	if link_timer > 0:
		if do_jump:
			new_input.actions.append("jump")
			do_jump = false
		new_input.input_direction = link_travel_direction
	
	if nav_agent.distance_to_target() < attack_range:
		new_input.actions.append("light_attack")
	
	return new_input


func _process(delta: float) -> void:
	if link_timer > 0:
		link_timer -= delta


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
