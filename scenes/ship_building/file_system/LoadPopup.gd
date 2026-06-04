class_name LoadPopup
extends Popup

@export var interface: ShipBuilderInterface
@export var file_scene: PackedScene
@export var list: VBoxContainer

func _ready() -> void:
	load_files()
	about_to_popup.connect(load_files)


func load_files():
	for child in list.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var preset_label := Label.new()
	preset_label.text = "Presets"
	list.add_child(preset_label)
	
	load_ship_files("res://resources/ship/presets/")
	
	var separator := HSeparator.new()
	list.add_child(separator)
	
	var saves_label := Label.new()
	saves_label.text = "Saves"
	list.add_child(saves_label)
	
	load_ship_files("user://" + ShipBuilderInterface.SAVE_FILEPATH)
	
	reset_size()


func load_ship_files(path: String):
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Could not open directory: " + path)
		return
	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".json"):
			var new_file = file_scene.instantiate() as ShipFile
			new_file.filename = filename.trim_suffix(".json")
			new_file.load_popup = self
			list.add_child(new_file)
		filename = dir.get_next()
	dir.list_dir_end()


func load_file(filename: String):
	interface.load_from_file(filename)
	hide()
