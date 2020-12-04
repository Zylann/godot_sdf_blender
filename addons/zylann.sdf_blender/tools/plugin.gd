tool
extends EditorPlugin

const SDFContainer = preload("../sdf_container.gd")
const SDFBox = preload("../sdf_box.gd")
const SDFSphere = preload("../sdf_sphere.gd")
const SDFTorus = preload("../sdf_torus.gd")
const SDFCylinder = preload("../sdf_cylinder.gd")

const SphereGizmo = preload("./sphere_gizmo.gd")
const BoxGizmo = preload("./box_gizmo.gd")
const CylinderGizmo = preload("./cylinder_gizmo.gd")
const TorusGizmo = preload("./torus_gizmo.gd")

var _gizmo_plugins := [
	SphereGizmo.new(),
	BoxGizmo.new(),
	CylinderGizmo.new(),
	TorusGizmo.new()
]


func _get_icon(icon_name: String):
	return load(str("res://addons/zylann.sdf_blender/tools/icons/icon_", icon_name, ".svg"))


func _enter_tree():
	add_custom_type("SDFContainer", "MeshInstance", SDFContainer, _get_icon("sdf_container"))
	add_custom_type("SDFBox", "Spatial", SDFBox, _get_icon("sdf_box"))
	add_custom_type("SDFSphere", "Spatial", SDFSphere, _get_icon("sdf_sphere"))
	add_custom_type("SDFTorus", "Spatial", SDFTorus, _get_icon("sdf_torus"))
	add_custom_type("SDFCylinder", "Spatial", SDFCylinder, _get_icon("sdf_cylinder"))
	
	for gizmo_plugin in _gizmo_plugins:
		gizmo_plugin.set_undo_redo(get_undo_redo())
		add_spatial_gizmo_plugin(gizmo_plugin)


func _exit_tree():
	remove_custom_type("SDFContainer")
	remove_custom_type("SDFBox")
	remove_custom_type("SDFSphere")
	remove_custom_type("SDFTorus")
	remove_custom_type("SDFCylinder")

	for gizmo_plugin in _gizmo_plugins:
		remove_spatial_gizmo_plugin(gizmo_plugin)
