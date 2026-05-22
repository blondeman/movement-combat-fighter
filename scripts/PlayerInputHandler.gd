class_name PlayerInputHandler
extends InputHandler

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
	
	if Input.is_action_just_pressed("attack"):
		new_input.actions.append("attack")
	
	return new_input
