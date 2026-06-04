class_name SettingsPopup
extends Popup

@export var layer_count: SpinBox
@export var node_count: SpinBox
var current_layer_count: int
var current_node_count: int

signal on_settings_changed(layer_count: int, node_count: int)

func _ready() -> void:
	about_to_popup.connect(set_current_values)
	reset_size()


func set_current_values():
	current_layer_count = int(layer_count.value)
	current_node_count = int(node_count.value)


func _on_cancel_pressed() -> void:
	hide()


func _on_save_pressed() -> void:
	if current_layer_count != layer_count.value or current_node_count != node_count.value:
		on_settings_changed.emit(layer_count.value, node_count.value)
	hide()
