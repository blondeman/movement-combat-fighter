extends Popup

@export var interface: ShipBuilderInterface
@export var line_edit: LineEdit
@export var error_text: Label

func _ready() -> void:
	error_text.visible = false
	reset_size()


func _on_cancel_pressed() -> void:
	hide()


func _on_save_pressed() -> void:
	var filename: String = line_edit.text
	
	if does_file_exist(filename):
		error_text.visible = true
	else:
		error_text.visible = false
		reset_size()
		interface.save_to_file(filename)
		hide()


func does_file_exist(filename: String):
	return false
