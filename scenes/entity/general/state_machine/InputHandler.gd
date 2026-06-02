@abstract class_name InputHandler extends Node

func get_input() -> InputPackage:
	var new_input = InputPackage.new()
	get_actions(new_input)
	get_combat_actions(new_input)
	return new_input

@abstract func get_actions(inputPackage: InputPackage)
@abstract func get_combat_actions(inputPackage: InputPackage)
