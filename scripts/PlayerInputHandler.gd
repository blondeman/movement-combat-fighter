class_name PlayerInputHandler
extends InputHandler


func get_actions(inputPackage: InputPackage):
	inputPackage.actions.append("idle")
	
	inputPackage.input_direction = Input.get_vector("left", "right", "up", "down")
	if inputPackage.input_direction != Vector2.ZERO:
		inputPackage.actions.append("run")
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera:
		inputPackage.camera_angle = camera.global_rotation.y
	
	if Input.is_action_pressed("jump"):
		inputPackage.actions.append("jump")
	
	if Input.is_action_pressed("dash"):
		inputPackage.actions.append("dash")
		if inputPackage.actions.has("jump"):
			inputPackage.actions.append("jump_dash")


func get_combat_actions(inputPackage: InputPackage):
	inputPackage.combat_actions.append("idle")
	
	if Input.is_action_pressed("attack"):
		inputPackage.combat_actions.append("light_attack")
