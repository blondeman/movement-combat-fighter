class_name InputHandler
extends Node

var _input_direction: Vector2


func get_input() -> InputPackage:
	var new_input = InputPackage.new()
	
	new_input.actions.append("idle")
	
	new_input.input_direction = Input.get_vector("left", "right", "up", "down")
	if new_input.input_direction != Vector2.ZERO:
		new_input.actions.append("run")
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera:
		new_input.camera_angle = camera.global_rotation.y
	
	if Input.is_action_pressed("jump"):
		new_input.actions.append("jump")
	
	if Input.is_action_pressed("dash"):
		new_input.actions.append("dash")
		if new_input.actions.has("jump"):
			new_input.actions.append("jump_dash")
	
	return new_input


func _process_directional():
	_input_direction = Input.get_vector("left", "right", "up", "down")
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera:
		var camera_angle: float = camera.global_rotation.y
		_input_direction = _input_direction.rotated(-camera_angle)
	
	#character_entity.set_input_direction(_input_direction)


func _process_jump():
	if Input.is_action_just_pressed("jump"):
		pass
		#character_entity.jump()


func _process_dash():
	if Input.is_action_just_pressed("dash"):
		var camera: Camera3D = get_viewport().get_camera_3d()
		var direction = Vector2.UP
		if camera:
			var camera_angle: float = camera.global_rotation.y
			direction = direction.rotated(-camera_angle)
		#character_entity.dash(direction)
