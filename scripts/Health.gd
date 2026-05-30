extends Node

@export var character: EntityController
@export var max_health: int = 100
var current_health: int = 0

@export_group("Hitstun")
@export var max_poise: int = 100
var current_poise: int = 0
@export var max_stun_timing = 0.3
@export var stun_curve: Curve
@export var min_stun_timing: float = 0.05
@export var poise_healing_time: float = 10
var last_hit_time: float = 0

signal on_take_damage(amount: int, current_health: int, max_health: int)
signal on_die()
signal on_calculated_hit_stun(stun_timing: float)

func _ready() -> void:
	current_health = max_health
	current_poise = max_poise


func take_damage(health_amount: int, poise_amount: int):
	current_health -= health_amount
	on_take_damage.emit(health_amount, current_health, max_health)
	
	current_poise -= poise_amount
	if current_poise <= 0:
		current_poise = 0
	
	if character.print_state:
		print("[" + get_parent().name + "]: " + str(current_health) + "/" + str(max_health))
		print("[" + get_parent().name + "]: " + str(current_poise) + "/" + str(max_poise))
	
	handle_hitstun()
	
	if current_health <= 0:
		die()


func die():
	on_die.emit()
	#get_parent().queue_free()


func _on_hitbox_on_take_damage(health_amount: int, poise_amount: int) -> void:
	take_damage(health_amount, poise_amount)


func handle_hitstun():
	var time_since_last_hit = Time.get_unix_time_from_system() - last_hit_time
	var healed_poise = int((time_since_last_hit / poise_healing_time) * max_poise)
	current_poise = min(current_poise + healed_poise, max_poise)
	
	var calculated_stun_timing = max_stun_timing
	calculated_stun_timing *= stun_curve.sample(float(current_poise) / float(max_poise))
	if calculated_stun_timing < min_stun_timing:
		calculated_stun_timing = 0.0
	on_calculated_hit_stun.emit(calculated_stun_timing)
	
	character.locomotion.change_state("hitstun")
	character.combat.change_state("hitstun")
	
	last_hit_time = Time.get_unix_time_from_system()
