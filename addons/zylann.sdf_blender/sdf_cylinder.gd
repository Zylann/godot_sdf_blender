@tool
@icon("res://addons/zylann.sdf_blender/tools/icons/icon_sdf_cylinder.svg")
class_name SDFCylinder extends SDFItem

@export var radius: float :
	get:
		return _data.params[SDF.PARAM_RADIUS].value
	set(r):
		radius = r # Useless but doing it anyways
		_set_param(SDF.PARAM_RADIUS, r)
@export var height:  float :
	get:
		return _data.params[SDF.PARAM_HEIGHT].value
	set(h):
		height = h # Useless but doing it anyways
		_set_param(SDF.PARAM_HEIGHT, h)
@export var rounding: float :
	get:
		return _get_param(SDF.PARAM_ROUNDING)
	set(r):
		rounding = r # Useless but doing it anyways
		_set_param(SDF.PARAM_ROUNDING, r)


func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_CYLINDER)
	set_notify_transform(true)
