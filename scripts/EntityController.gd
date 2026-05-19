extends CharacterBody3D

@export var input_handler: InputHandler
@export var locomotion: StateMachine
@export var momentum_decay: float = 4.0
@export var air_momentum_decay: float = 1.0

@export var dash_cooldown: float = 1.2
var dash_cooldown_remaining: float = 0.0

@export var coyote_time: float = 0.12
var coyote_timer: float = 0.0
var was_on_floor: bool = false

var momentum: Vector3 = Vector3.ZERO

func _physics_process(delta: float):
	if dash_cooldown_remaining > 0:
		dash_cooldown_remaining -= delta
		
	if was_on_floor and not is_on_floor():
		coyote_timer = coyote_time
	elif is_on_floor():
		coyote_timer = 0.0
	if coyote_timer > 0:
		coyote_timer -= delta
	was_on_floor = is_on_floor()
	
	if input_handler:
		var input = input_handler.get_input()
		locomotion.update(delta, input)

func is_on_floor_or_coyote() -> bool:
	return is_on_floor() or coyote_timer > 0.0
