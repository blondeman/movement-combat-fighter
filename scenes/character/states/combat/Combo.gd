class_name Combo
extends CombatState

@export var combo_window_start: float = 0.4

func default_lifecycle(input: InputPackage) -> String:
	if works_longer_than(combo_window_start):
		if input.combat_actions.has(get_parent_state_name()):
			return get_next_combo()
	
	if works_longer_than(animation_length):
		attacked = false
		return best_input_that_can_be_paid(input)
	
	return "okay"

func get_parent_state_name() -> String:
	var parent := get_parent()
	while parent.get_parent() is Combo:
		parent = parent.get_parent()
	
	if parent is Combo:
		return parent.state_name
	
	return state_name

func get_next_combo() -> String:
	if get_child_count() > 0:
		return get_child(0).state_name
	
	return get_parent_state_name()
