tool
extends EditorSpatialGizmoPlugin

const SDFBox = preload("../sdf_box.gd")

var _undo_redo : UndoRedo

const _cube_lines = [
	Vector3(-1, -1, -1),
	Vector3(1, -1, -1),
	Vector3(-1, 1, -1),
	Vector3(1, 1, -1),
	Vector3(-1, -1, 1),
	Vector3(1, -1, 1),
	Vector3(-1, 1, 1),
	Vector3(1, 1, 1),

	Vector3(-1, -1, -1),
	Vector3(-1, 1, -1),
	Vector3(1, -1, -1),
	Vector3(1, 1, -1),
	Vector3(-1, -1, 1),
	Vector3(-1, 1, 1),
	Vector3(1, -1, 1),
	Vector3(1, 1, 1),

	Vector3(-1, -1, -1),
	Vector3(-1, -1, 1),
	Vector3(1, -1, -1),
	Vector3(1, -1, 1),
	Vector3(-1, 1, -1),
	Vector3(-1, 1, 1),
	Vector3(1, 1, -1),
	Vector3(1, 1, 1)
]

func _init():
	create_handle_material("handles_billboard", false)
	# TODO This is supposed to create an "on-top" material, but it still renders behind...
	# See https://github.com/godotengine/godot/issues/44077
	create_material("lines", Color(1, 1, 1), false, true, false)


func set_undo_redo(ur: UndoRedo):
	_undo_redo = ur


func get_name() -> String:
	return "SDFBoxGizmo"


func has_gizmo(spatial: Spatial) -> bool:
	return spatial is SDFBox


func get_handle_value(gizmo: EditorSpatialGizmo, index: int):
	var node : SDFBox = gizmo.get_spatial_node()
	return node.size[index]


func set_handle(gizmo: EditorSpatialGizmo, index: int, camera: Camera, screen_point: Vector2):
	var node : SDFBox = gizmo.get_spatial_node()

	var ray_pos := camera.project_ray_origin(screen_point)
	var ray_dir := camera.project_ray_normal(screen_point)

	var axis := index

	var gtrans := node.global_transform

	var seg0 := gtrans.origin - 4096.0 * gtrans.basis[axis]
	var seg1 := gtrans.origin + 4096.0 * gtrans.basis[axis]

	var hits := Geometry.get_closest_points_between_segments(
		seg0, seg1, ray_pos, ray_pos + ray_dir * 4096.0)

	var hit = gtrans.affine_inverse() * hits[0]
	var size = node.size
	size[axis] = hit[axis]
	node.size = size


func commit_handle(gizmo: EditorSpatialGizmo, index: int, restore, cancel := false):
	var node : SDFBox = gizmo.get_spatial_node()
	var ur := _undo_redo
	
	ur.create_action("Set SDFBox size")
	ur.add_do_property(node, "radius", node.size)
	ur.add_undo_property(node, "radius", restore)
	ur.commit_action()


func redraw(gizmo: EditorSpatialGizmo):
	gizmo.clear()
	
	var node : SDFBox = gizmo.get_spatial_node()
	var size := node.size

	var points := []
	for p in _cube_lines:
		points.append(p * size)

	var handles := []
	for axis in 3:
		var h = Vector3()
		h[axis] = size[axis]
		handles.append(h)
	
	gizmo.add_lines(PoolVector3Array(points), get_material("lines", gizmo), false)
	gizmo.add_handles(PoolVector3Array(handles), get_material("handles_billboard", gizmo), false)


