extends CombatState

var stun_timing: float = 0.0

func default_lifecycle(input: InputPackage) -> String:
	if works_longer_than(stun_timing):
		return best_input_that_can_be_paid(input)
	else:
		return "okay"


func _on_health_on_calculated_hit_stun(timing: float) -> void:
	stun_timing = timing
