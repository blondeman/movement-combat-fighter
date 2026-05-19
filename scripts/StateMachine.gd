class_name StateMachine
extends Node

@export var character: CharacterBody3D

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


func change_state(new_state: String) -> void:
	if current_state:
		print(current_state.state_name + " -> " + new_state)
		current_state._exit()
	current_state = states[new_state]
	current_state._enter()


func state_priority_sort(a : String, b : String):
	if states[a].priority > states[b].priority:
		return true
	else:
		return false
