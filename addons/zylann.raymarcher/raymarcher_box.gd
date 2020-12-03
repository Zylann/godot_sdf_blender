tool
#class_name RaymarcherBox
extends "./raymarcher_item.gd"


export(Vector3) var size : Vector3 setget set_size, get_size
export(float) var rounding setget set_rounding, get_rounding


func _init():
	_data = Raymarcher.SceneObject.new(Raymarcher.SHAPE_BOX)


func get_size() -> Vector3:
	return _data.params[Raymarcher.PARAM_SIZE].value


func set_size(s: Vector3):
	size = s # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_SIZE, s)


func get_rounding() -> float:
	return _get_param(Raymarcher.PARAM_ROUNDING)


func set_rounding(r: float):
	rounding = r # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_ROUNDING, r)

