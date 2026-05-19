extends Node3D

var character_entity: CharacterEntity
var _input_direction: Vector2

func _ready():
	if get_parent() is not CharacterEntity:
		push_error("Must be child of CharacterEntity")
	character_entity = get_parent() as CharacterEntity


func _process(delta: float) -> void:
	_process_directional()
	_process_jump()
	_process_dash()


func _process_directional():
	_input_direction = Input.get_vector("left", "right", "up", "down")
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera:
		var camera_angle: float = camera.global_rotation.y
		_input_direction = _input_direction.rotated(-camera_angle)
	
	character_entity.set_input_direction(_input_direction)


func _process_jump():
	if Input.is_action_just_pressed("jump"):
		character_entity.jump()


func _process_dash():
	if Input.is_action_just_pressed("dash"):
		var camera: Camera3D = get_viewport().get_camera_3d()
		var direction = Vector2.UP
		if camera:
			var camera_angle: float = camera.global_rotation.y
			direction = direction.rotated(-camera_angle)
		character_entity.dash(direction)
