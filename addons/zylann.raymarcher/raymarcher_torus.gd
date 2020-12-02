tool
extends "./raymarcher_item.gd"


export(float) var radius setget set_radius, get_radius
export(float) var thickness setget set_thickness, get_thickness


func _init():
	_data = Raymarcher.SceneObject.new(Raymarcher.SHAPE_TORUS)


func get_radius() -> float:
	return _data.params[Raymarcher.PARAM_RADIUS].value


func set_radius(r: float):
	radius = r # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_RADIUS, r)


func get_thickness() -> float:
	return _get_param(Raymarcher.PARAM_THICKNESS)


func set_thickness(r: float):
	thickness = r # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_THICKNESS, r)

