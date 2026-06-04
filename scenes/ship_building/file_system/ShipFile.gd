class_name ShipFile
extends HBoxContainer

var load_popup: LoadPopup
var filename: String = ""

@export var preview_button: Button

func _ready() -> void:
	preview_button.text = filename


func _on_load_pressed() -> void:
	load_popup.load_file(filename)
