@tool
extends EditorNode3DGizmoPlugin

const SDFBox = preload("../sdf_box.gd")

var _undo_redo : EditorUndoRedoManager

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


func set_undo_redo(ur: EditorUndoRedoManager):
	_undo_redo = ur


func get_name() -> String:
	return "SDFBoxGizmo"


func _has_gizmo(spatial: Node3D) -> bool:
	return spatial is SDFBox


func _get_handle_value(gizmo: EditorNode3DGizmo, index: int, secondary := false):
	var node : SDFBox = gizmo.get_spatial_node()
	return node.size[index]


func _set_handle(gizmo: EditorNode3DGizmo, index: int, secondary : bool, camera: Camera3D, screen_point: Vector2):
	var node : SDFBox = gizmo.get_spatial_node()

	var ray_pos := camera.project_ray_origin(screen_point)
	var ray_dir := camera.project_ray_normal(screen_point)

	var axis := index

	var gtrans := node.global_transform

	var seg0 := gtrans.origin - 4096.0 * gtrans.basis[axis]
	var seg1 := gtrans.origin + 4096.0 * gtrans.basis[axis]

	var hits := Geometry3D.get_closest_points_between_segments(
		seg0, seg1, ray_pos, ray_pos + ray_dir * 4096.0)

	var hit = gtrans.affine_inverse() * hits[0]
	var size = node.size
	size[axis] = hit[axis]
	node.size = size


func _commit_handle(gizmo: EditorNode3DGizmo, index: int, secondary, restore, cancel := false):
	var node : SDFBox = gizmo.get_spatial_node()
	var ur := _undo_redo
	
	ur.create_action("Set SDFBox size")
	ur.add_do_property(node, "radius", node.size)
	ur.add_undo_property(node, "radius", restore)
	ur.commit_action()


func _redraw(gizmo: EditorNode3DGizmo):
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
	
	gizmo.add_lines(PackedVector3Array(points), get_material("lines", gizmo), false)
	var ids:=PackedInt32Array()
	gizmo.add_handles(PackedVector3Array(handles), get_material("handles_billboard", gizmo), ids, false, false)


