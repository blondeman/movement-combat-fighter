extends Node

var active_scene: Node
@export var scene_paths: Array[String] = [
	"res://scenes/testing/debugger.tscn"
]

var transition_directory: String = "res://scenes/transitions/"

func _ready():
	active_scene = get_tree().current_scene
	
	for scene_path in scene_paths:
		var new_scene = (load(scene_path) as PackedScene).instantiate()
		get_tree().root.add_child.call_deferred(new_scene)


func load_scene_file(file: String, transition_id: int = -1):
	var packed_scene = load(file) as PackedScene
	if packed_scene:
		load_scene(packed_scene, transition_id)
	else:
		push_error("SceneManager: Failed to load scene from path: " + file)


func load_scene(scene: PackedScene, transition_id: int = -1):
	await transition_in(transition_id)
	
	if active_scene:
		active_scene.queue_free()
	
	await transition_out(transition_id)
	
	var new_scene = scene.instantiate()
	get_tree().root.add_child(new_scene)
	active_scene = new_scene


func transition_in(transition_id: int):
	if transition_id == -1:
		return
	await get_tree().create_timer(1.0).timeout


func transition_out(transition_id: int):
	if transition_id == -1:
		return
	await get_tree().create_timer(1.0).timeout
