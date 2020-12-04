tool


# See https://github.com/godotengine/godot/issues/21113
static func Plane_from_point_normal(p: Vector3, n: Vector3) -> Plane:
	n = n.normalized()
	return Plane(n, p.dot(n))


#static func _create_wiresphere_mesh() -> ArrayMesh:
#	var r := 1.0
#	var point_count := 32
#
#	var positions := []
#
#	for i in point_count:
#		var angle = TAU * float(i) / float(point_count)
#		positions.append(r * Vector3(cos(angle), sin(angle), 0.0))
#
#	for i in point_count:
#		var angle = TAU * float(i) / float(point_count)
#		positions.append(r * Vector3(cos(angle), 0.0, sin(angle)))
#
#	for i in point_count:
#		var angle = TAU * float(i) / float(point_count)
#		positions.append(r * Vector3(0.0, cos(angle), sin(angle)))
#
#	var indices := []
#	for i in point_count:
#		var i2 = (i + 1) % point_count
#		indices.append(i)
#		indices.append(i2)
#		indices.append(point_count + i)
#		indices.append(point_count + i2)
#		indices.append(2 * point_count + i)
#		indices.append(2 * point_count + i2)
#
#	var arrays := []
#	arrays.resize(ArrayMesh.ARRAY_MAX)
#	arrays[ArrayMesh.ARRAY_VERTEX] = PoolVector3Array(positions)
#	arrays[ArrayMesh.ARRAY_INDEX] = PoolIntArray(indices)
#
#	var mesh = ArrayMesh.new()
#	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
#
#	return mesh


#static func get_point_line_distance(
#	point: Vector3, line_point: Vector3, line_dir: Vector3) -> float:
#
#	var u := point - line_point
#	var v := u.project(line_dir)
#	var d := sqrt(u.length() - v.length())
#	return d

