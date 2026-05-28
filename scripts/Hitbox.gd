class_name Hitbox
extends Area3D

func take_damage(amount: float):
	print(get_parent().name + " got hit for "+str(amount)+" damage")
