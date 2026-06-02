extends LocomotionState

@export var momentum_decay: float = 10
var stun_timing: float = 0.0


func update(delta: float, input: InputPackage):
	character.velocity.y -= gravity * delta
	character.move_and_slide()


func default_lifecycle(input: InputPackage) -> String:
	if works_longer_than(stun_timing):
		return best_input_that_can_be_paid(input)
	else:
		return "okay"


func process_input_vector(delta: float, input: InputPackage):
	decay_horizontal_velocity(momentum_decay, delta)


func _on_health_on_calculated_hit_stun(timing: float) -> void:
	stun_timing = timing
