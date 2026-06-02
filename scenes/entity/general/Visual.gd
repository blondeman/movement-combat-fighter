class_name Visual
extends Node3D

@export var animation_player: AnimationPlayer
@export var blend_state: BlendStateSwitch
@export var weapon: Weapon


func play(state: State):
	if state.is_blend_space:
		blend_state.connect_blend_space(state.animation_name)
	else:
		if state is LocomotionState:
			blend_state.connect_locomotion_animation(state.animation_name)
		if state is CombatState:
			blend_state.connect_combat_animation(state.animation_name)
			if weapon:
				weapon.set_data(state as CombatState)

func set_hitbox_active(is_attacking: bool):
	if weapon:
		weapon.set_active(is_attacking)

func reset_weapon():
	if weapon:
		weapon.reset()

func set_blend_space_2d_position(direction: Vector2):
	blend_state.set_blend_space_2d_position(direction)
