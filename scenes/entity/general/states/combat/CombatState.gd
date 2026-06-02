class_name CombatState
extends State

@export var health_damage: int = 10
@export var poise_damage: int = 10
@export var animation_length: float = 0.7

const attack_timing = 0.1

var attacked := false


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


func _exit():
	state_machine.visual.reset_weapon()
	exit()


func is_weapon_hitbox_active() -> bool:
	var animation_player: AnimationParameters = state_machine.visual.animation_player as AnimationParameters
	var data: Animation = animation_player.get_animation(animation_name)
	
	var track = data.find_track("AnimationParameters:is_weapon_hitbox_active", Animation.TYPE_VALUE)
	return animation_player.get_boolean_value(animation_name, track, get_progress())
