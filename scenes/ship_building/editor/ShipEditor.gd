extends Path2D

@export var node_scene: PackedScene
@export var points: Array[PathNode]
@export var visual: ShipEditorVisual

func _ready() -> void:
	var i := 0
	for child in get_children():
		if child is PathNode:
			points.append(child)
			child.index = i
			child.node_changed.connect(set_curve_point)
			i += 1
		
	generate_curve()


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
	curve.set_point_position(idx, points[idx].position)
	curve.set_point_in(idx, points[idx].arm_a.position)
	curve.set_point_out(idx, points[idx].arm_b.position)

	visual.update_path(curve)
