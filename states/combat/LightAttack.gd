extends CombatState


func update(delta: float, input: InputPackage):
	process_attack(input)


func process_attack(input: InputPackage):
	if works_longer_than(attack_timing) and not attacked:
		attacked = true
