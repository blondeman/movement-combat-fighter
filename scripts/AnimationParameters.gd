class_name AnimationParameters
extends AnimationPlayer

@export var is_weapon_hitbox_active: bool

func get_boolean_value(animation : String, track : int, timecode : float) -> bool:
	var data: Animation = get_animation(animation)
	return data.value_track_interpolate(track, timecode)
