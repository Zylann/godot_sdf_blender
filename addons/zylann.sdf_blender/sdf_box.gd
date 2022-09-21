@tool
extends "./sdf_item.gd"


@export var size: Vector3 :
	get:
		return _data.params[SDF.PARAM_SIZE].value
	set(s):
		size = s # Useless but doing it anyways
		_set_param(SDF.PARAM_SIZE, s)
@export var rounding: float :
	get:
		return _get_param(SDF.PARAM_ROUNDING)
	set(r):
		rounding = r # Useless but doing it anyways
		_set_param(SDF.PARAM_ROUNDING, r)


func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_BOX)
	set_notify_transform(true) 



