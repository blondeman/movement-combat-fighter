class_name ShipBuilderInterface
extends Control

const SAVE_FILEPATH: String = "ships/"

@export var layer_container: Control
@export var layers: Array[ShipBuilderLayerEditor]

@export var save_popup: Popup
@export var load_popup: Popup

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
	on_ship_changed.emit(get_ship_data())


func get_ship_data() -> Array[PackedVector2Array]:
	var ship_data: Array[PackedVector2Array]
	for child in layer_container.get_children():
		if child is ShipBuilderLayerEditor:
			ship_data.append(child.layer_data)
	return ship_data


func _on_save_pressed() -> void:
	save_popup.popup_centered()


func _on_load_pressed() -> void:
	load_popup.popup_centered()


func save_to_file(filename: String):
	var ship_data := get_ship_data()
	
	var serialized: Array = []
	for packed_arr in ship_data:
		var layer: Array = []
		for vec in packed_arr:
			layer.append({ "x": vec.x, "y": vec.y })
		serialized.append(layer)
	
	var json_string := JSON.stringify(serialized, "\t")
	
	var path := SAVE_FILEPATH + filename + ".json"
	DirAccess.make_dir_recursive_absolute("user://" + SAVE_FILEPATH)
	
	var file := FileAccess.open("user://" + path, FileAccess.WRITE)
	if file == null:
		push_error("ShipBuilderInterface: could not open file for writing: " + path)
		return
	
	file.store_string(json_string)
	file.close()
	print("Saved successfully to " + ProjectSettings.globalize_path("user://" + path))


func load_from_file(filename: String):
	print("Loading from "+filename)
