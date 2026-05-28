class_name Weapon
extends Area3D

var ignore_list: Array[Hitbox]
var is_attacking: bool = true
var damage: float = 10


func set_data(state: CombatState):
	damage = state.damage


func _on_area_entered(area: Area3D) -> void:
	if !is_attacking:
		return
	if !area is Hitbox or area in ignore_list:
		return 
	
	var hit_data := area as Hitbox
	ignore_list.append(hit_data)
	
	hit_data.take_damage(damage)


func reset():
	ignore_list.clear()
	is_attacking = false
