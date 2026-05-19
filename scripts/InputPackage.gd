extends Resource
class_name InputPackage

var actions : Array[String]
var combat_actions : Array[String]

var input_direction : Vector2
var camera_angle : float

func get_camera_direction() -> Vector2:
	return Vector2.UP.rotated(-camera_angle)

func get_rotated_input() -> Vector2:
	return input_direction.rotated(-camera_angle)
	
