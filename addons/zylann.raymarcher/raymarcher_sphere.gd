tool
#class_name RaymarcherSphere
extends "./raymarcher_item.gd"


export(float) var radius : float setget set_radius, get_radius


func _init():
	_data = Raymarcher.SceneObject.new(Raymarcher.SHAPE_SPHERE)


func get_radius() -> float:
	return _data.params[Raymarcher.PARAM_RADIUS].value


func set_radius(r: float):
	radius = r # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_RADIUS, r)


