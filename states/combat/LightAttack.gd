extends CombatState


func default_lifecycle(input: InputPackage) -> String:
	if works_longer_than(animation_length):
		attacked = false
		return "idle"
	else:
		return "okay"
