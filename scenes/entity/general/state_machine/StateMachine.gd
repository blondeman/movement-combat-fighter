@icon("res://icons/chart-diagram-solid-full.svg")
class_name StateMachine
extends Node

@export var character: EntityController
@export var visual: Visual
@export var print_state: bool = true

var current_state: State
var states: Dictionary

signal on_state_changed(from: State, to: State)

func _ready():
	get_states_in_children(self)
	change_state("idle")


func get_states_in_children(node: Node):
	for child in node.get_children():
		if child is State:
			states[child.state_name] = child
			child.character = character
			child.state_machine = self
		get_states_in_children(child)


func update(delta: float, input: InputPackage):
	var relevance = current_state.check_relevance(input)
	if relevance != "okay":
		change_state(relevance)
	current_state._update(delta, input)
	
	if current_state.is_blend_space:
		var input_direction = input.get_input_direction()
		var blend_space_position = Vector2(input_direction.x, input_direction.z)
		visual.set_blend_space_2d_position(blend_space_position)


func change_state(new_state: String) -> void:
	var previous_state = current_state
	if print_state and character.print_state:
		var machine_name = "["+name+"]"
		if current_state:
			print(machine_name + current_state.state_name + " -> " + new_state)
		else:
			print(machine_name + " -> " + new_state)
	
	if current_state:
		current_state._exit()
	
	if states.has(new_state):
		current_state = states[new_state]
	else:
		current_state = states["idle"]
	
	on_state_changed.emit(previous_state, current_state)
	
	current_state._enter()
	visual.play(current_state)


func state_priority_sort(a : String, b : String):
	if !states.has(a):
		return false
	if !states.has(b):
		return true
	
	if states[a].priority > states[b].priority:
		return true
	else:
		return false
