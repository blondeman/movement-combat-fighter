class_name LoadPopup
extends Popup

@export var interface: ShipBuilderInterface
@export var file_scene: PackedScene
@export var list: VBoxContainer

func _ready() -> void:
	load_files()


func load_files():
	for i in range(6):
		var new_file = file_scene.instantiate() as ShipFile
		new_file.filename = "ship_" + str(i + 1)
		new_file.load_popup = self
		list.add_child(new_file)
	reset_size()


func load_file(filename: String):
	interface.load_from_file(filename)
	hide()
