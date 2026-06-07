class_name Health
extends Node

@export var character: EntityController
@export var max_health: int = 100
var current_health: float = 0

@export_group("Poise")
@export var max_poise: int = 100
var current_poise: float = 0
@export var poise_regen_rate: float = 10.0
@export var poise_recover_threshold: float = 50

@export_group("Hitstun")
@export var base_stun_duration: float = 0.3
@export var min_stun_duration: float = 0.05
@export var stun_decay: float = 0.6
var consecutive_stun_count: int = 0

var is_poise_broken: bool = false

signal on_health_changed(amount: int, current_health: int, max_health: int)
signal on_poise_changed(amount: int, current_poise: int, max_poise: int)
signal on_die()
signal on_calculated_hit_stun(stun_timing: float)
signal on_poise_broken()
signal on_poise_recovered()


func _ready() -> void:
	current_health = max_health
	current_poise = max_poise


func _process(delta: float) -> void:
	if current_poise < max_poise:
		current_poise = min(current_poise + poise_regen_rate * delta, max_poise)
		on_poise_changed.emit(poise_regen_rate * delta, current_poise, max_poise)

	if is_poise_broken:
		if current_poise >= poise_recover_threshold:
			_recover_poise()


func take_damage(health_amount: int, poise_amount: int) -> void:
	current_health -= health_amount
	on_health_changed.emit(-health_amount, current_health, max_health)

	if character.print_state:
		print("[%s]: HP %d/%d  Poise %d/%d  Broken: %s" % [
			get_parent().name, int(current_health), max_health,
			int(current_poise), max_poise, is_poise_broken
		])
	
	if current_health <= 0:
		die()
		return

	take_poise_damage(poise_amount)
	on_poise_changed.emit(-poise_amount, current_poise, max_poise)


func take_poise_damage(poise_amount: int):
	if !is_poise_broken:
		current_poise -= poise_amount
		if current_poise <= 0:
			current_poise = 0
			_break_poise()

	if is_poise_broken:
		_apply_hitstun()


func _break_poise() -> void:
	is_poise_broken = true
	consecutive_stun_count = 0
	on_poise_broken.emit()


func _recover_poise() -> void:
	is_poise_broken = false
	consecutive_stun_count = 0
	on_poise_recovered.emit()


func _apply_hitstun() -> void:
	var stun = base_stun_duration * pow(stun_decay, consecutive_stun_count)
	stun = maxf(stun, min_stun_duration)
	consecutive_stun_count += 1

	on_calculated_hit_stun.emit(stun)
	character.locomotion.change_state("hitstun")
	character.combat.change_state("hitstun")


func die() -> void:
	current_health = 0
	on_die.emit()


func _on_hitbox_on_take_damage(health_amount: int, poise_amount: int) -> void:
	take_damage(health_amount, poise_amount)
