class_name EntityController
extends CharacterBody3D

@export_group("StateMachine")
@export var input_handler: InputHandler
@export var locomotion: StateMachine

@export_group("Movement")
@export var momentum_decay: float = 4.0
@export var air_momentum_decay: float = 1.0
@export var air_acceleration : float = 2.0

@export_group("Cooldowns")
@export var dash_cooldown: float = 1.2
var dash_cooldown_remaining: float = 0.0

@export var coyote_time: float = 0.12
var coyote_timer: float = 0.0
var was_on_floor: bool = false


var lock_target: Node3D = null

@export_group("Debug Options")
@export var print_state: bool = false

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
	
	if global_position.y < -10:
		velocity = Vector3.ZERO
		global_position = Vector3.ZERO

func is_on_floor_or_coyote() -> bool:
	return is_on_floor() or coyote_timer > 0.0
