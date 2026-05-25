class_name StateMachine
extends Node

@export var character: EntityController
@export var visual: Visual

var current_state: State
var states: Dictionary

func _ready():
	for child in get_children():
		if child is State:
			states[child.state_name] = child
			child.character = character
			child.state_machine = self
	change_state("idle")


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
	if current_state:
		if character.print_state:
			print(current_state.state_name + " -> " + new_state)
		current_state._exit()
	else:
		if character.print_state:
			print(" -> " + new_state)
	current_state = states[new_state]
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
