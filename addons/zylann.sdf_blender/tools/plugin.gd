@tool
extends EditorPlugin

const SphereGizmo = preload("./sphere_gizmo.gd")
const BoxGizmo = preload("./box_gizmo.gd")
const CylinderGizmo = preload("./cylinder_gizmo.gd")
const TorusGizmo = preload("./torus_gizmo.gd")

var _gizmo_plugins : Array[Variant] = [
	SphereGizmo.new(),
	BoxGizmo.new(),
	CylinderGizmo.new(),
	TorusGizmo.new()
]


func _get_icon(icon_name: String):
	return load(str("res://addons/zylann.sdf_blender/tools/icons/icon_", icon_name, ".svg"))


func _enter_tree():
	for gizmo_plugin in _gizmo_plugins:
		gizmo_plugin.set_undo_redo(get_undo_redo())
		add_node_3d_gizmo_plugin(gizmo_plugin)



func _exit_tree():
	for gizmo_plugin in _gizmo_plugins:
		remove_node_3d_gizmo_plugin(gizmo_plugin)
