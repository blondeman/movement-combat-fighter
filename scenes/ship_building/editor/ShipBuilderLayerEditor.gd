class_name ShipBuilderLayerEditor
extends Control

@export var label: Label
@export var layer_data: PackedVector2Array
@export var layer_path_data: Array[PathNode]
@export var editor: ShipEditor
var idx: int = 0

signal ship_changed(idx: int)
signal path_changed(idx: int)

func set_layer_id(layer: int):
	idx = layer
	label.text = "Layer "+str(layer + 1)


func set_layer_data(data: PackedVector2Array):
	layer_data = data
	ship_changed.emit(idx)


func set_path_data(points: Array[PathNode]):
	layer_path_data = points
	path_changed.emit(idx)
