class_name ShipEditorVisual
extends Line2D

func update_path(curve: Curve2D):
	clear_points()
	
	default_color = Color(1,1,1,1)
	for point in curve.get_baked_points():
		add_point(point)
