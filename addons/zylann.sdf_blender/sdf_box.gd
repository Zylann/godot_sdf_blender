tool
extends "./sdf_item.gd"


export(Vector3) var size : Vector3 setget set_size, get_size
export(float) var rounding setget set_rounding, get_rounding


func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_BOX)


func get_size() -> Vector3:
	return _data.params[SDF.PARAM_SIZE].value


func set_size(s: Vector3):
	size = s # Useless but doing it anyways
	_set_param(SDF.PARAM_SIZE, s)


func get_rounding() -> float:
	return _get_param(SDF.PARAM_ROUNDING)


func set_rounding(r: float):
	rounding = r # Useless but doing it anyways
	_set_param(SDF.PARAM_ROUNDING, r)

