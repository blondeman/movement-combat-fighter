class_name Hitbox
extends Area3D

@export var character: EntityController
signal on_take_damage(health_amount: int, poise_amount: int)

func take_damage(health_amount: int, poise_amount: int):
	on_take_damage.emit(health_amount, poise_amount)
