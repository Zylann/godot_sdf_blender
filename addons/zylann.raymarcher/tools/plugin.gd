tool
extends EditorPlugin

const Raymarcher = preload("../raymarcher.gd")
const RaymarcherBox = preload("../raymarcher_box.gd")
const RaymarcherSphere = preload("../raymarcher_sphere.gd")
const RaymarcherTorus = preload("../raymarcher_torus.gd")


func _get_icon(icon_name: String):
	return load(str("res://addons/zylann.raymarcher/tools/icons/icon_", icon_name, ".svg"))


func _enter_tree():
	add_custom_type("Raymarcher", "MeshInstance", Raymarcher, _get_icon("sdf_container"))
	add_custom_type("RaymarcherBox", "Spatial", RaymarcherBox, _get_icon("sdf_box"))
	add_custom_type("RaymarcherSphere", "Spatial", RaymarcherSphere, _get_icon("sdf_sphere"))
	add_custom_type("RaymarcherTorus", "Spatial", RaymarcherTorus, _get_icon("sdf_torus"))


func _exit_tree():
	remove_custom_type("Raymarcher")
	remove_custom_type("RaymarcherBox")
	remove_custom_type("RaymarcherSphere")
	remove_custom_type("RaymarcherTorus")

