class_name BlendStateSwitch
extends AnimationTree

var current_blend_space: String = ""

func set_blend_space_2d_position(direction: Vector2):
	if current_blend_space.is_empty():
		return
	set("parameters/" + current_blend_space + "/blend_position", direction)

func connect_blend_space(blend_space: String):
	var blend_tree: AnimationNodeBlendTree = tree_root as AnimationNodeBlendTree
	if not blend_tree:
		push_error("tree_root is not an AnimationNodeBlendTree")
		return

	for i in blend_tree.get_node("output").get_input_count():
		blend_tree.disconnect_node("output", i)

	blend_tree.connect_node("output", 0, blend_space)
	current_blend_space = blend_space
