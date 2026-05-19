extends Node3D

var character_entity: CharacterEntity

@export var max_health: int = 100
var current_health: int = 0

signal on_take_damage(amount: int, current_health: int, max_health: int)
signal on_die()

func _ready() -> void:
	if get_parent() is not CharacterEntity:
		push_error("Must be child of CharacterEntity")
	character_entity = get_parent() as CharacterEntity
	
	current_health = max_health


func take_damage(amount: int):
	current_health -= amount
	on_take_damage.emit(amount, current_health, max_health)
	
	if current_health <= 0:
		die()


func die():
	on_die.emit()
	character_entity.queue_free()
