extends Path2D

@export var node_scene: PackedScene
@export var visual: ShipEditorVisual
@export var visual_mirror: ShipEditorVisual
@export var layer_editor: ShipBuilderLayerEditor

var points: Array[PathNode]


func _ready() -> void:
	generate_points(4)
	generate_curve()


func generate_points(count: int):
	for child in get_children():
		child.queue_free()
	
	for i in range(count):
		var new_node = node_scene.instantiate() as PathNode
		add_child(new_node)
		points.append(new_node)
		new_node.index = i
		new_node.node_changed.connect(set_curve_point)
		
		var x_position: float = (i - float(count - 1) / 2) * 200
		if i == 0:
			new_node.enable_arm_a(false)
			new_node.position = Vector2(x_position, 0)
		elif i == count - 1:
			new_node.enable_arm_b(false)
			new_node.position = Vector2(x_position, 0)
		else:
			new_node.position = Vector2(x_position, 100)
		
		if i > 0:
			new_node.arm_a.position = \
			(points[i - 1].position - new_node.position) \
			.normalized() * 50
		new_node.update_nodes()


func generate_curve() -> void:
	while curve.point_count < points.size():
		curve.add_point(Vector2.ZERO)
	while curve.point_count > points.size():
		curve.remove_point(curve.point_count - 1)
	
	set_curve_points()


func set_curve_points():
	for i in range(points.size()):
		set_curve_point(i)


func set_curve_point(idx: int):
	if idx == 0 or idx == points.size() - 1:
		points[idx].global_position.y = 0
	elif points[idx].global_position.y < 0:
		points[idx].global_position.y = 0
	
	if points[idx].arm_a.global_position.y < 0:
		points[idx].arm_a.global_position.y = 0
	
	if points[idx].arm_b.global_position.y < 0:
		points[idx].arm_b.global_position.y = 0
	
	curve.set_point_position(idx, points[idx].position)
	curve.set_point_in(idx, points[idx].arm_a.position)
	curve.set_point_out(idx, points[idx].arm_b.position)

	visual.update_path(curve)
	visual_mirror.update_path(curve)
	
	if layer_editor:
		layer_editor.set_layer_data(get_baked_ship(50))


func get_baked_ship(resolution: int) -> PackedVector2Array:
	var points := curve.get_baked_points()
	var mirrored := PackedVector2Array()
	for point in points:
		mirrored.append(Vector2(point.x, -point.y))
	mirrored.reverse()
	var full := points + mirrored

	var result := PackedVector2Array()
	var total := full.size()
	for i in range(resolution):
		var t := float(i) / float(resolution) * total
		var idx := int(t)
		var frac := t - idx
		var p0 := full[idx % total]
		var p1 := full[(idx + 1) % total]
		result.append(p0.lerp(p1, frac))
	return result
