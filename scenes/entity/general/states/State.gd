class_name State
extends Node

signal state_finished(next_state_name: String)

@export_group("Animation Settings")
@export var animation_name : String = "RESET"
@export var animation_blend_time : float = -1
@export var is_blend_space : bool = false

@export_group("State Settings")
@export var state_name : String
@export var priority : int
@export var can_loop: bool = false

var enter_state_time : float
var initial_position : Vector3
var frame_length = 0.016

var state_machine: StateMachine
var character: EntityController

func check_relevance(input : InputPackage) -> String:
	return default_lifecycle(input)


func default_lifecycle(input : InputPackage) -> String:
	return best_input_that_can_be_paid(input)


func best_input_that_can_be_paid(input : InputPackage) -> String:
	input.actions.sort_custom(state_machine.state_priority_sort)
	for action in input.actions:
		if state_machine.states[action] == self and !can_loop:
			return "okay"
		if state_machine.states.has(action):
			return action
	return "error"


func mark_enter_state():
	enter_state_time = Time.get_unix_time_from_system()


func get_progress() -> float:
	var now = Time.get_unix_time_from_system()
	return now - enter_state_time


func works_longer_than(time : float) -> bool:
	if get_progress() >= time:
		return true
	return false

func works_less_than(time : float) -> bool:
	if get_progress() < time: 
		return true
	return false

func works_between(start : float, finish : float) -> bool:
	var progress = get_progress()
	if progress >= start and progress <= finish:
		return true
	return false


func _enter():
	mark_enter_state()
	enter()

func enter():
	pass

func _exit():
	exit()

func exit():
	pass

func _update(delta: float, input: InputPackage):
	update(delta, input)

func update(delta: float, input: InputPackage):
	pass
