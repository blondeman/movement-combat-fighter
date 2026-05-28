class_name CombatState
extends State

@export var damage: float = 10.0
@export var animation_length: float = 0.7

const attack_timing = 0.1

var attacked : bool = false

func default_lifecycle(input: InputPackage) -> String:
	if works_longer_than(animation_length):
		attacked = false
		
		return best_input_that_can_be_paid(input)
	else:
		return "okay"


func best_input_that_can_be_paid(input : InputPackage) -> String:
	input.combat_actions.sort_custom(state_machine.state_priority_sort)
	for action in input.combat_actions:
		if state_machine.states[action] == self and !can_loop:
			return "okay"
		if state_machine.states.has(action):
			return action
	return "error"
