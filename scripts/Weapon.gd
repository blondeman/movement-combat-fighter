class_name Weapon
extends Area3D

var ignore_list: Array[Hitbox]
var is_attacking: bool = true
var health_damage: int = 10
var poise_damage: int = 10


func set_data(state: CombatState):
	health_damage = state.health_damage
	poise_damage = state.poise_damage
	ignore_list.append(state.character.hitbox)


func set_active(_is_attacking: bool):
	is_attacking = _is_attacking
	if is_attacking:
		for area in get_overlapping_areas():
			_on_area_entered(area)


func _on_area_entered(area: Area3D) -> void:
	if !is_attacking:
		return
	if !area is Hitbox or area in ignore_list:
		return
	
	var hit_data := area as Hitbox
	ignore_list.append(hit_data)
	
	hit_data.take_damage(health_damage, poise_damage)


func reset():
	ignore_list.clear()
	is_attacking = false
