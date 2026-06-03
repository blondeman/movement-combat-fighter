extends Control

@export var layer_container: Control
@export var layers: Array[ShipBuilderLayerEditor]

signal on_ship_changed(ship_data: Array[PackedVector2Array])

func _ready() -> void:
	set_layer_names()


func set_layer_names():
	var i: int = 0
	for child in layer_container.get_children():
		if child is ShipBuilderLayerEditor:
			child.set_layer_id(i)
			child.ship_changed.connect(update_layer)
			i += 1
			update_layer(i)


func update_layer(idx: int):
	var ship_data: Array[PackedVector2Array]
	for child in layer_container.get_children():
		if child is ShipBuilderLayerEditor:
			ship_data.append(child.layer_data)
	on_ship_changed.emit(ship_data)
