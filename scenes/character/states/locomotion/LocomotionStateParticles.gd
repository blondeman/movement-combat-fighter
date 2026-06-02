class_name LocomotionStateParticles
extends LocomotionState

@export var particles: PackedScene
@export var offset: Vector3 = Vector3(0, 0.5, 0)

func create_particles(direction: Vector3 = Vector3.ZERO):
	var new_particles = particles.instantiate() as CPUParticles3D
	get_tree().root.add_child(new_particles)
	new_particles.global_position = character.global_position + offset
	new_particles.direction = direction
	new_particles.emitting = true
