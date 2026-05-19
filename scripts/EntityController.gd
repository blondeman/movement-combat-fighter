extends CharacterBody3D

@export var input_handler: InputHandler
@export var locomotion: StateMachine

func _physics_process(delta: float):
	if input_handler:
		var input = input_handler.get_input()
		locomotion.update(delta, input)
