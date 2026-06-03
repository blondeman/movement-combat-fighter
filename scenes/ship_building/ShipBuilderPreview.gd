extends Node3D

@export var mesh: MeshInstance3D
@export var data_scale: float = 0.5
@export var layer_spacing: float = 5

func rebuild_ship(ship_data: Array[PackedVector2Array]):
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(ship_data.size() - 1):
		var layer_a := ship_data[i]
		var layer_b := ship_data[i + 1]
		var y_a := (ship_data.size() - 1 - i) * layer_spacing
		var y_b := (ship_data.size() - 2 - i) * layer_spacing

		var point_count := mini(layer_a.size(), layer_b.size())
		for j in range(point_count):
			var a := Vector3(layer_a[j].x, y_a, layer_a[j].y)                       * data_scale
			var b := Vector3(layer_b[j].x, y_b, layer_b[j].y)                       * data_scale
			var a_next := Vector3(layer_a[(j + 1) % point_count].x, y_a, layer_a[(j + 1) % point_count].y)   * data_scale
			var b_next := Vector3(layer_b[(j + 1) % point_count].x, y_b, layer_b[(j + 1) % point_count].y)   * data_scale

			st.add_vertex(a)
			st.add_vertex(b_next)
			st.add_vertex(b)

			st.add_vertex(a)
			st.add_vertex(a_next)
			st.add_vertex(b_next)

	for cap in [0, ship_data.size() - 1]:
		var layer := ship_data[cap]
		var y: float = (ship_data.size() - 1 - cap) * layer_spacing
		var point_count := layer.size()
		var center := Vector3.ZERO
		for p in layer:
			center += Vector3(p.x, y, p.y) * data_scale
		center /= point_count

		for j in range(point_count):
			var a := Vector3(layer[j].x, y, layer[j].y) * data_scale
			var b := Vector3(layer[(j + 1) % point_count].x, y, layer[(j + 1) % point_count].y) * data_scale

			if cap == 0:
				st.add_vertex(center)
				st.add_vertex(b)
				st.add_vertex(a)
			else:
				st.add_vertex(center)
				st.add_vertex(a)
				st.add_vertex(b)

	st.index()
	st.generate_normals()
	mesh.mesh = st.commit()
	
	var mat := StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat
