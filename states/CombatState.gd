class_name CombatState
extends LocomotionState

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


func update(delta: float, input: InputPackage):
	process_attack(input)
	process_rotation(delta, input.get_input_direction())
	character.move_and_slide()


func process_attack(input: InputPackage):
	if works_longer_than(attack_timing) and not attacked:
		attacked = true
		
		if (character.velocity * Vector3(1,0,1)).length() < speed:
			var face_direction = character.basis.z
			character.velocity = face_direction * speed
