tool
#class_name RaymarcherBox
extends "./raymarcher_item.gd"


export(Vector3) var size setget set_size, get_size


func _init():
	_data = Raymarcher.SceneObject.new(Raymarcher.SHAPE_BOX)


func get_size() -> float:
	return _data.params[Raymarcher.PARAM_SIZE].value


func set_size(s: Vector3):
	size = s # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_SIZE, s)


