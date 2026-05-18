extends Node3D

var character_entity: CharacterEntity
var _input_direction: Vector2

func _ready():
	if get_parent() is not CharacterEntity:
		push_error("Must be child of CharacterEntity")
	character_entity = get_parent() as CharacterEntity


func _process(delta: float) -> void:
	_input_direction = Input.get_vector("left", "right", "up", "down")
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera:
		var camera_angle: float = camera.global_rotation.y
		_input_direction = _input_direction.rotated(-camera_angle)
	
	character_entity.set_input_direction(_input_direction)
