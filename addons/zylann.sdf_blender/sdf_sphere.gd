@tool
@icon("res://addons/zylann.sdf_blender/tools/icons/icon_sdf_sphere.svg")
class_name SDFSphere extends SDFItem


@export var radius: float :
	get:
		return _data.params[SDF.PARAM_RADIUS].value
	set(r):
		radius = r # Useless but doing it anyways
		_set_param(SDF.PARAM_RADIUS, r)



func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_SPHERE)
	set_notify_transform(true)
