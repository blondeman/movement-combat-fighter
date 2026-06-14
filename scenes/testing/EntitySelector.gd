extends PanelContainer

var tilde_held: bool = false
var tracked_entity: EntityController

var _labels: Dictionary = {}

@export var label_parent: Control

var label_keys: Array[String] = [
	"entity", 
	"locomotion", 
	"combat", 
	"health", 
	"poise"
]

var _signal_bindings: Array[Array] = [
	[func(e): return e.locomotion, "on_state_changed", "locomotion_state_changed"],
	[func(e): return e.combat, "on_state_changed", "combat_state_changed"],
	[func(e): return e.health, "on_health_changed", "health_changed"],
	[func(e): return e.health, "on_poise_changed", "poise_changed"],
]

func _ready():
	_rebuild_labels()
	set_process_input(true)

func _input(event: InputEvent):
	# Tilde key toggle
	if event is InputEventKey and event.keycode == KEY_QUOTELEFT:
		if event.pressed and not tilde_held:
			tilde_held = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif not event.pressed:
			tilde_held = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Left click to select while tilde is held
	if tilde_held and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_try_select_at(event.position)

func _try_select_at(screen_pos: Vector2):
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	var space_state := get_viewport().get_world_3d().direct_space_state
	var origin := camera.project_ray_origin(screen_pos)
	var direction := camera.project_ray_normal(screen_pos)

	var query := PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * 1000.0
	)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := space_state.intersect_ray(query)
	if result.is_empty():
		select_entity(null)
		return

	var hit: Node = result.collider

	var entity: EntityController = _find_entity_controller(hit)
	if entity:
		select_entity(entity)
	else:
		select_entity(null)


func _find_entity_controller(node: Node) -> EntityController:
	var current := node
	while current:
		if current is EntityController:
			return current
		current = current.get_parent()
	return null


func select_entity(entity: EntityController) -> void:
	if tracked_entity:
		_bind_signals(tracked_entity, false)
	
	tracked_entity = entity
	if tracked_entity:
		_bind_signals(tracked_entity, true)
	_rebuild_labels()


func _rebuild_labels() -> void:
	for child in label_parent.get_children():
		child.queue_free()
	_labels.clear()

	if !tracked_entity:
		var label := Label.new()
		label.text = "Entity: null"
		label_parent.add_child(label)
		return
	
	for key in label_keys:
		var label := Label.new()
		_labels[key] = label
		label_parent.add_child(label)

	_labels["entity"].text = "Entity: %s" % tracked_entity.name
	_labels["locomotion"].text = "Locomotion: %s" % tracked_entity.locomotion.current_state.name
	_labels["combat"].text = "Combat: %s" % tracked_entity.combat.current_state.name
	_labels["health"].text = "Health: %s / %s" % [tracked_entity.health.current_health, tracked_entity.health.max_health]
	_labels["poise"].text = "Poise: %s / %s" % [tracked_entity.health.current_poise, tracked_entity.health.max_poise]


func _bind_signals(entity: EntityController, do_connect: bool) -> void:
	for binding in _signal_bindings:
		var component = binding[0].call(entity)
		var sig: Signal = component.get(binding[1])
		var handler: Callable = Callable(self, binding[2])
		if do_connect:
			sig.connect(handler)
		else:
			sig.disconnect(handler)


func locomotion_state_changed(from: State, to: State) -> void:
	_labels["locomotion"].text = "Locomotion: %s" % to.name


func combat_state_changed(from: State, to: State) -> void:
	_labels["combat"].text = "Combat: %s" % to.name


func health_changed(amount: int, current_health: int, max_health: int) -> void:
	_labels["health"].text = "Health: %s / %s" % [current_health, max_health]


func poise_changed(amount: int, current_poise: int, max_poise: int) -> void:
	_labels["poise"].text = "Poise: %s / %s" % [current_poise, max_poise]
