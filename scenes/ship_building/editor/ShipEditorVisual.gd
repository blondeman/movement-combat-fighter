class_name ShipEditorVisual
extends Line2D

@export var is_mirrored: bool = false

func update_path(curve: Curve2D):
	var baked_points: PackedVector2Array = curve.get_baked_points()
	if baked_points.size() == points.size():
		for i in range(baked_points.size()):
			set_point_position(
				i, 
				baked_points[i] * Vector2(1, -1 if is_mirrored else 1)
			)
	else:
		clear_points()
		for point in baked_points:
			add_point(point * Vector2(1, -1 if is_mirrored else 1))
