class_name Weapon
extends Area3D

var ignore_list: Array[Hitbox]
var is_attacking: bool = true
var health_damage: int = 10
var poise_damage: int = 10
var character: EntityController


func set_data(state: CombatState):
	health_damage = state.health_damage
	poise_damage = state.poise_damage
	character = state.character

func _on_area_entered(area: Area3D) -> void:
	ignore_list.append(character.hitbox)
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
