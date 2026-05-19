class_name State
extends Node

signal state_finished(next_state_name: String)

@export var state_name : String
@export var priority : int

var state_machine: StateMachine
var character: CharacterBody3D

func check_relevance(input : InputPackage) -> String:
	#if accepts_queueing():
		#check_combos(input)
	#
	#if has_queued_move and transitions_to_queued():
		#try_force_move(queued_move)
		#has_queued_move = false
	
	return default_lifecycle(input)


func default_lifecycle(input : InputPackage):
	return best_input_that_can_be_paid(input)


func best_input_that_can_be_paid(input : InputPackage) -> String:
	input.actions.sort_custom(state_machine.state_priority_sort)
	for action in input.actions:
		if state_machine.states[action] == self:
			return "okay"
		else:
			return action
	return "error"


func enter():
	pass

func exit():
	pass

func update(delta: float, input: InputPackage):
	pass
