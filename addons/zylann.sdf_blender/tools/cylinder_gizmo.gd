tool
extends EditorSpatialGizmoPlugin

const SDFCylinder = preload("../sdf_cylinder.gd")

const INDEX_RADIUS = 0
const INDEX_HEIGHT = 1

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
	return "SDFCylinderGizmo"


func has_gizmo(spatial: Spatial) -> bool:
	return spatial is SDFCylinder


func get_handle_value(gizmo: EditorSpatialGizmo, index: int):
	var node : SDFCylinder = gizmo.get_spatial_node()
	match index:
		INDEX_RADIUS:
			return node.radius
		INDEX_HEIGHT:
			return node.height


func set_handle(gizmo: EditorSpatialGizmo, index: int, camera: Camera, screen_point: Vector2):
	var node : SDFCylinder = gizmo.get_spatial_node()

	var ray_pos := camera.project_ray_origin(screen_point)
	var ray_dir := camera.project_ray_normal(screen_point)

	var gtrans := node.global_transform
	
	match index:
		INDEX_RADIUS:
			node.radius = _get_axis_distance(gtrans, ray_pos, ray_dir, Vector3.AXIS_X)
		
		INDEX_HEIGHT:
			node.height = _get_axis_distance(gtrans, ray_pos, ray_dir, Vector3.AXIS_Y)


static func _get_axis_distance(
	gtrans: Transform, ray_origin: Vector3, ray_dir: Vector3, axis: int) -> float:
	
	var seg0 := gtrans.origin - 4096.0 * gtrans.basis[axis]
	var seg1 := gtrans.origin + 4096.0 * gtrans.basis[axis]

	var hits := Geometry.get_closest_points_between_segments(
		seg0, seg1, ray_origin, ray_origin + ray_dir * 4096.0)

	var hit = gtrans.affine_inverse() * hits[0]
	return hit[axis]


func commit_handle(gizmo: EditorSpatialGizmo, index: int, restore, cancel := false):
	var node : SDFCylinder = gizmo.get_spatial_node()
	var ur := _undo_redo
	
	match index:
		INDEX_RADIUS:
			ur.create_action("Set SDFCylinder radius")
			ur.add_do_property(node, "radius", node.radius)
			ur.add_undo_property(node, "radius", restore)
			ur.commit_action()

		INDEX_HEIGHT:
			ur.create_action("Set SDFCylinder height")
			ur.add_do_property(node, "height", node.height)
			ur.add_undo_property(node, "height", restore)
			ur.commit_action()


func redraw(gizmo: EditorSpatialGizmo):
	gizmo.clear()
	
	var node : SDFCylinder = gizmo.get_spatial_node()
	var height := node.height
	var radius := node.radius
	
	var points := []
	var angle_step := TAU / float(POINT_COUNT)
	var heights = [-height, height]
	var radius_xz = Vector3(radius, 1, radius)
	
	# Top and bottom caps
	for i in POINT_COUNT:
		var angle := float(i) * angle_step
		for h in heights:
			points.append(radius_xz * Vector3(cos(angle), h, sin(angle)))
			points.append(radius_xz * Vector3(cos(angle + angle_step), h, sin(angle + angle_step)))
	
	# Lines to connect caps
	var lines_angle_step := TAU / 4.0
	var lines_angle_start := PI / 4.0
	for i in 4:
		var p := polar2cartesian(radius, lines_angle_start + float(i) * lines_angle_step)
		points.append(Vector3(p.x, -height, p.y))
		points.append(Vector3(p.x, height, p.y))

	var handles := [
		Vector3(radius, 0, 0),
		Vector3(0, height, 0)
	]
	
	gizmo.add_lines(PoolVector3Array(points), get_material("lines", gizmo), false)
	gizmo.add_handles(PoolVector3Array(handles), get_material("handles_billboard", gizmo), false)


