class_name PathNode
extends Node2D

signal node_changed(index: int)

@export var use_second_handle: bool = true

@export_group("References")
@export var center: Area2D
@export var arm_a: Area2D
@export var arm_b: Area2D

@export var line_a: Line2D
@export var line_b: Line2D

var _dragging: Area2D = null
var _drag_offset: Vector2 = Vector2.ZERO
var index: int = 0

func _ready() -> void:
	for area in [center, arm_a, arm_b]:
		area.input_pickable = true
		area.connect("input_event", _on_area_input_event.bind(area))

func _on_area_input_event(_viewport, event: InputEvent, _shape_idx: int, area: Area2D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = area
			if area == center:
				_drag_offset = global_position - get_global_mouse_position()
			else:
				_drag_offset = area.global_position - get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if _dragging == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_dragging = null
		return
	if event is InputEventMouseMotion:
		if _dragging == center:
			global_position = get_global_mouse_position() + _drag_offset
		else:
			_dragging.global_position = get_global_mouse_position() + _drag_offset
			line_a.points[1] = arm_a.position
			line_b.points[1] = arm_b.position
		node_changed.emit(index)
