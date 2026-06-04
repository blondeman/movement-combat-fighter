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
	layers.clear()
	
	var i: int = 0
	for child in layer_container.get_children():
		if child is ShipBuilderLayerEditor:
			child.set_layer_id(i)
			child.ship_changed.connect(update_layer)
			i += 1
			update_layer(i)
			layers.append(child)


func update_layer(idx: int):
	on_ship_changed.emit(get_ship_data())


func get_path_data() -> Array:
	var path_data: Array = []
	for i in layers.size():
		var layer_nodes: Array = []
		for node in layers[i].layer_path_data:
			layer_nodes.append({
				"position": { "x": node.position.x, "y": node.position.y },
				"arm_a": { "x": node.arm_a.position.x, "y": node.arm_a.position.y },
				"arm_b": { "x": node.arm_b.position.x, "y": node.arm_b.position.y }
			})
		path_data.append(layer_nodes)
	return path_data


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
	var json_string := JSON.stringify(get_path_data(), "\t")
	var path := SAVE_FILEPATH + filename + ".json"
	DirAccess.make_dir_recursive_absolute("user://" + SAVE_FILEPATH)
	
	var file := FileAccess.open("user://" + path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open file for writing: " + path)
		return
	
	file.store_string(json_string)
	file.close()
	
	print(ProjectSettings.globalize_path("user://" + path))


func load_from_file(filename: String):
	print("Loading from " + filename)
	var path := "user://" + SAVE_FILEPATH + filename + ".json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open file for reading: " + path)
		return
	
	var data: Array = JSON.parse_string(file.get_as_text())
	file.close()
	
	for i in layers.size():
		layers[i].editor.generate_from_data(data[i])
