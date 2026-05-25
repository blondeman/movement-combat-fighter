class_name Visual
extends Node3D

@export var animation_player: AnimationPlayer
@export var blend_state: BlendStateSwitch


func play(state: State):
	if state.is_blend_space:
		play_blend_state(state.animation_name)
	else:
		play_animation(state.animation_name, state.animation_blend_time)


func play_animation(animation_name: String, blend_time: float = -1):
	blend_state.active = false
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	else:
		animation_player.stop()


func play_blend_state(animation_name: String):
	animation_player.stop()
	blend_state.active = true
	blend_state.connect_blend_space(animation_name)


func set_blend_space_2d_position(direction: Vector2):
	blend_state.set_blend_space_2d_position(direction)
