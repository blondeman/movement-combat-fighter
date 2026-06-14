extends Control

@export var container: VBoxContainer

var scene_list: Array = [
	"res://scenes/testing/test_environment.tscn",
	"res://scenes/ship_building/ship_builder_interface.tscn",
	"res://scenes/levels/village.tscn",
]


func _ready():
	create_buttons()


func create_buttons():
	for scene in scene_list:
		var button = Button.new()
		button.text = scene.get_file().get_basename()
		button.pressed.connect(load_scene.bind(scene))
		container.add_child(button)
	container.reset_size()


func load_scene(scene: String):
	SceneManager.load_scene_file(scene)
