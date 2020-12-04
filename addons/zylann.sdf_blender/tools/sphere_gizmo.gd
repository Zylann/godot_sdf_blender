tool
extends EditorSpatialGizmoPlugin

const SDFSphere = preload("../sdf_sphere.gd")
const Util = preload("../util/util.gd")

const POINT_COUNT = 32

var _undo_redo : UndoRedo


func _init():
	create_handle_material("handles_billboard", true)
	# TODO This is supposed to create an "on-top" material, but it still renders behind...
	# See https://github.com/godotengine/godot/issues/44077
	create_material("lines_billboard", Color(1, 1, 1), true, true, false)


func set_undo_redo(ur: UndoRedo):
	_undo_redo = ur


func get_name() -> String:
	return "SDFSphereGizmo"


func has_gizmo(spatial: Spatial) -> bool:
	return spatial is SDFSphere


func get_handle_value(gizmo: EditorSpatialGizmo, index: int):
	var node : SDFSphere = gizmo.get_spatial_node()
	return node.radius


func set_handle(gizmo: EditorSpatialGizmo, index: int, camera: Camera, screen_point: Vector2):
	var node : SDFSphere = gizmo.get_spatial_node()
	var center := node.global_transform.origin
	var pos := camera.project_ray_origin(screen_point)
	var dir := camera.project_ray_normal(screen_point)
	var plane := Util.Plane_from_point_normal(center, camera.global_transform.basis.z)
	# TODO Scale?
	var hit = plane.intersects_ray(pos, dir)
	if hit != null:
		var r : float = hit.distance_to(center)
		node.radius = r


func commit_handle(gizmo: EditorSpatialGizmo, index: int, restore, cancel := false):
	var node : SDFSphere = gizmo.get_spatial_node()
	var ur := _undo_redo
	
	# Spheres have only one handle
	assert(index == 0)
	
	ur.create_action("Set SDFSphere radius")
	ur.add_do_property(node, "radius", node.radius)
	ur.add_undo_property(node, "radius", restore)
	ur.commit_action()


func redraw(gizmo: EditorSpatialGizmo):
	gizmo.clear()
	
	var node : SDFSphere = gizmo.get_spatial_node()
	var radius := node.radius

	var points := []
	var angle_step := TAU / float(POINT_COUNT)
	
	for i in POINT_COUNT:
		var angle := float(i) * angle_step
		points.append(radius * Vector3(cos(angle), sin(angle), 0.0))
		points.append(radius * Vector3(cos(angle + angle_step), sin(angle + angle_step), 0.0))

	# Why do we have to send "true" for the billboard parameter, when the material already has it?
	gizmo.add_lines(PoolVector3Array(points), get_material("lines_billboard", gizmo), true)
	
	var handles := PoolVector3Array([Vector3(radius, 0, 0)])
	gizmo.add_handles(handles, get_material("handles_billboard", gizmo), true)

