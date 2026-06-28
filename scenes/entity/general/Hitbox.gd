class_name Hitbox
extends Area3D

@export var character: EntityController
@export var hit_effect: PackedScene
signal on_take_damage(health_amount: int, poise_amount: int)

func take_damage(health_amount: int, poise_amount: int, hit_position: Vector3, hit_direction: Vector3):
	on_take_damage.emit(health_amount, poise_amount)
	instance_hit_effect(hit_position)
	character.add_force(hit_direction)


func instance_hit_effect(hit_position: Vector3):
	var new_hit_effect = hit_effect.instantiate() as CPUParticles3D
	get_tree().root.add_child(new_hit_effect)
	new_hit_effect.global_position = hit_position
	new_hit_effect.emitting = true
