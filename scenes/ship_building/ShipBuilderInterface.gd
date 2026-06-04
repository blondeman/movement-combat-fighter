class_name ShipBuilderInterface
extends Control

const SAVE_FILEPATH: String = "ships/"

@export var layer_container: Control
@export var layers: Array[ShipBuilderLayerEditor]
@export var layer_editor_scene: PackedScene
@export var separator_style_box: StyleBoxLine

@export var save_popup: Popup
@export var load_popup: LoadPopup
@export var settings_popup: SettingsPopup

signal on_ship_changed(ship_data: Array[PackedVector2Array])

func _ready() -> void:
	generate_default_layers(2, 4)


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
	
	var layer_count = 2 if data.size() < 2 else data.size()
	var node_count = 3 if data.is_empty() else data[0].size()
	set_settings(layer_count, node_count)
	
	await set_layer_count(data.size())
	
	for i in data.size():
		layers[i].editor.generate_from_data(data[i])


func generate_default_layers(layer_count: int, node_count: int):
	set_settings(layer_count, node_count)
	await set_layer_count(layer_count)
	
	for i in range(layer_count):
		layers[i].editor.generate_points(node_count)


func set_settings(layer_count: int, node_count: int):
	settings_popup.layer_count.value = layer_count
	settings_popup.node_count.value = node_count


func set_layer_count(count: int):
	layers.clear()
	
	for child in layer_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	for i in range(count):
		var new_layer_editor_scene = layer_editor_scene.instantiate() as ShipBuilderLayerEditor
		layers.append(new_layer_editor_scene)
		layer_container.add_child(new_layer_editor_scene)
		
		new_layer_editor_scene.set_layer_id(i)
		new_layer_editor_scene.ship_changed.connect(update_layer)
		
		if i < count - 1:
			var separator := HSeparator.new()
			separator.add_theme_stylebox_override("separator", separator_style_box)
			layer_container.add_child(separator)


func _on_save_pressed() -> void:
	save_popup.popup_centered()


func _on_load_pressed() -> void:
	load_popup.popup_centered()


func _on_settings_pressed() -> void:
	settings_popup.popup_centered()
