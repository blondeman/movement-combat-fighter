class_name CharacterEntity
extends CharacterBody3D


@export var speed = 5.0

var _input_direction: Vector2
var lock_target: Node3D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := (transform.basis * Vector3(_input_direction.x, 0, _input_direction.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func set_input_direction(_direction: Vector2):
	_input_direction = _direction


func set_lock_target(_target: Node3D):
	lock_target = _target
