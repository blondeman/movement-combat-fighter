extends Node

@export var target_health: Health

@export var health_bar: TextureProgressBar
@export var poise_bar: TextureProgressBar

func _ready():
	if !target_health:
		for child in get_parent().get_children():
			if child is Health:
				target_health = child
				break
	
	if target_health:
		set_signals()


func set_signals():
	target_health.on_health_changed.connect(_take_damage)
	target_health.on_poise_changed.connect(_take_poise_damage)
	_take_damage(target_health.max_health, target_health.current_health, target_health.max_health)
	_take_poise_damage(target_health.max_poise, target_health.current_poise, target_health.max_poise)


func _take_damage(amount: int, current_health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current_health


func _take_poise_damage(amount: int, current_poise: int, max_poise: int):
	poise_bar.max_value = max_poise
	poise_bar.value = current_poise
