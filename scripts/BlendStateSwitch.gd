class_name BlendStateSwitch
extends AnimationTree

var current_blend_space: String = ""
var blend_tree: AnimationNodeBlendTree


func _ready() -> void:
	blend_tree = tree_root as AnimationNodeBlendTree
	if not blend_tree:
		push_error("tree_root is not an AnimationNodeBlendTree")


func set_blend_space_2d_position(direction: Vector2):
	if current_blend_space.is_empty():
		return
	set("parameters/" + current_blend_space + "/blend_position", direction)


func connect_blend_space(blend_space: String):
	blend_tree.disconnect_node("state_mixer", 0)
	blend_tree.connect_node("state_mixer", 0, blend_space)
	current_blend_space = blend_space


func connect_locomotion_animation(animation_name: String):
	blend_tree.disconnect_node("state_mixer", 0)
	blend_tree.connect_node("state_mixer", 0, "locomotion_seek")
	current_blend_space = ""
	
	blend_tree.get_node("locomotion").animation = animation_name
	set("parameters/locomotion_seek/seek_request", 0.0)


func connect_combat_animation(animation_name: String):
	blend_tree.get_node("combat").animation = animation_name
	
	if animation_name != "RESET":
		set("parameters/combat_seek/seek_request", 0.0)
		set("parameters/state_mixer/blend_amount", 1.0)
	else:
		set("parameters/state_mixer/blend_amount", 0.0)
	
