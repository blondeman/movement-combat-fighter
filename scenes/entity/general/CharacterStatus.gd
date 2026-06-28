class_name CharacterStatus
extends Node

@export_group("Dash")
@export var dash_cooldown: float = 1.2
var dash_cooldown_remaining: float = 0.0

@export_group("Coyote Time")
@export var coyote_time: float = 0.12
var coyote_timer: float = 0.0
var _was_on_floor: bool = false

@export_group("Ledge Slide")
@export var max_ledge_slide_time: float = 1.5
var ledge_slide_time: float = 0.0
var ledge_wall_normal: Vector3 = Vector3.ZERO

var invulnerable: bool = false

func tick(delta: float, on_floor: bool) -> void:
	if dash_cooldown_remaining > 0:
		dash_cooldown_remaining -= delta

	if _was_on_floor and not on_floor:
		coyote_timer = coyote_time
	elif on_floor:
		coyote_timer = 0.0
	if coyote_timer > 0:
		coyote_timer -= delta
	_was_on_floor = on_floor


func can_dash() -> bool:
	return dash_cooldown_remaining <= 0.0


func start_dash_cooldown() -> void:
	dash_cooldown_remaining = dash_cooldown


func consume_coyote() -> void:
	coyote_timer = 0.0


func is_on_floor_or_coyote(on_floor: bool) -> bool:
	return on_floor or coyote_timer > 0.0


func can_slide() -> bool:
	return ledge_slide_time < max_ledge_slide_time
