extends Line2D

@export var path: Path2D

func _ready() -> void:
	update_path()

func update_path():
	default_color = Color(1,1,1,1)
	for point in path.curve.get_baked_points():
		add_point(point + path.position)
