class_name CharacterEntity
extends CharacterBody3D


@export var speed = 5.0
@export var jump_velocity = 10.0
@export var dash_velocity = 20.0

@export_category("Damping")
@export var stop_damp = 100.0
@export var floor_damp = 40.0
@export var air_damp = 10.0

var _input_direction: Vector2
var lock_target: Node3D

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_physics_process_grounded(delta)
	else:
		_physics_process_airborne(delta)

	move_and_slide()


func _physics_process_grounded(delta: float):
	var direction := (transform.basis * Vector3(_input_direction.x, 0, _input_direction.y)).normalized()
	var xz_velocity := Vector2(velocity.x, velocity.z)
	
	if xz_velocity.length() > speed + .1:
		##Dashing
		var target: Vector2 = Vector2(direction.x, direction.z) * speed if direction else Vector2.ZERO
		var new_xz := xz_velocity.move_toward(target, floor_damp * delta)
		velocity.x = new_xz.x
		velocity.z = new_xz.y
	elif direction:
		##Moving
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		##Stopping
		var new_xz := xz_velocity.move_toward(Vector2.ZERO, stop_damp * delta)
		velocity.x = new_xz.x
		velocity.z = new_xz.y


func _physics_process_airborne(delta: float):
	velocity += get_gravity() * delta
	
	var direction := (transform.basis * Vector3(_input_direction.x, 0, _input_direction.y)).normalized()
	var xz_velocity := Vector2(velocity.x, velocity.z)
	
	var target: Vector2 = Vector2(direction.x, direction.z) * speed if direction else Vector2.ZERO
	var new_xz := xz_velocity.move_toward(target, air_damp * delta)
	velocity.x = new_xz.x
	velocity.z = new_xz.y


func jump():
	if is_on_floor():
		velocity.y = jump_velocity


func dash(default_direction: Vector2):
	var direction: Vector3 = (transform.basis * Vector3(_input_direction.x, 0, _input_direction.y)).normalized()
	if !direction:
		direction = (transform.basis * Vector3(default_direction.x, 0, default_direction.y)).normalized()
	velocity.x = direction.x * dash_velocity
	velocity.z = direction.z * dash_velocity


func set_input_direction(_direction: Vector2):
	_input_direction = _direction


func set_lock_target(_target: Node3D):
	lock_target = _target
