extends CombatState


func update(delta: float, input: InputPackage):
	process_attack(input)
	state_machine.visual.set_hitbox_active(is_weapon_hitbox_active())


func process_attack(input: InputPackage):
	if works_longer_than(attack_timing) and not attacked:
		attacked = true
