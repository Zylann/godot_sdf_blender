@tool
extends EditorNode3DGizmoPlugin

const SDFTorus = preload("../sdf_torus.gd")

const INDEX_RADIUS = 0
const INDEX_THICKNESS = 1

const POINT_COUNT = 32

var _undo_redo : UndoRedo


func _init():
	create_handle_material("handles_billboard", false)
	# TODO This is supposed to create an "on-top" material, but it still renders behind...
	# See https://github.com/godotengine/godot/issues/44077
	create_material("lines", Color(1, 1, 1), false, true, false)


func set_undo_redo(ur: UndoRedo):
	_undo_redo = ur


func get_name() -> String:
	return "SDFTorusGizmo"


func has_gizmo(spatial: Node3D) -> bool:
	return spatial is SDFTorus


func _get_handle_value(gizmo: EditorNode3DGizmo, index:int, secondary:=false):
	var node : SDFTorus = gizmo.get_spatial_node()
	match index:
		INDEX_RADIUS:
			return node.radius
		INDEX_THICKNESS:
			return node.thickness


func set_handle(gizmo: EditorNode3DGizmo, index: int, camera: Camera3D, screen_point: Vector2):
	var node : SDFTorus = gizmo.get_spatial_node()

	var ray_pos := camera.project_ray_origin(screen_point)
	var ray_dir := camera.project_ray_normal(screen_point)

	var gtrans := node.global_transform
	var d := _get_axis_distance(gtrans, ray_pos, ray_dir, Vector3.AXIS_X)

	match index:
		INDEX_RADIUS:
			node.radius = d
		INDEX_THICKNESS:
			node.thickness = d - node.radius


static func _get_axis_distance(
	gtrans: Transform3D, ray_origin: Vector3, ray_dir: Vector3, axis: int) -> float:
	
	var seg0 := gtrans.origin - 4096.0 * gtrans.basis[axis]
	var seg1 := gtrans.origin + 4096.0 * gtrans.basis[axis]

	var hits := Geometry3D.get_closest_points_between_segments(
		seg0, seg1, ray_origin, ray_origin + ray_dir * 4096.0)

	var hit = gtrans.affine_inverse() * hits[0]
	return hit[axis]


func _commit_handle(gizmo: EditorNode3DGizmo, index: int,secondary, restore, cancel := false):
	var node : SDFTorus = gizmo.get_spatial_node()
	var ur := _undo_redo
	
	match index:
		INDEX_RADIUS:
			ur.create_action("Set SDFTorus radius")
			ur.add_do_property(node, "radius", node.radius)
			ur.add_undo_property(node, "radius", restore)
			ur.commit_action()

		INDEX_THICKNESS:
			ur.create_action("Set SDFTorus thickness")
			ur.add_do_property(node, "thickness", node.thickness)
			ur.add_undo_property(node, "thickness", restore)
			ur.commit_action()


func redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	
	var node : SDFTorus = gizmo.get_spatial_node()
	var radius := node.radius
	var thickness := node.thickness

	var points := []
	var angle_step := TAU / float(POINT_COUNT)
	var radii := [radius - thickness, radius + thickness]
	
	for i in POINT_COUNT:
		var angle := float(i) * angle_step
		for r in radii:
			points.append(r * Vector3(cos(angle), 0, sin(angle)))
			points.append(r * Vector3(cos(angle + angle_step), 0, sin(angle + angle_step)))
	
	var handles := [
		Vector3(radius, 0, 0),
		Vector3(radius + thickness, 0, 0)
	]
	
	var ids:=PackedInt32Array()
	gizmo.add_lines(PackedVector3Array(points), get_material("lines", gizmo), false)
	gizmo.add_handles(PackedVector3Array(handles), get_material("handles_billboard", gizmo), ids, false, false)


