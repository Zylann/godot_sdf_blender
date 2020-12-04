tool
extends "./raymarcher_item.gd"


export(float) var radius : float setget set_radius, get_radius
export(float) var height : float setget set_height, get_height
export(float) var rounding : float setget set_rounding, get_rounding


func _init():
	_data = Raymarcher.SceneObject.new(Raymarcher.SHAPE_CYLINDER)


func get_radius() -> float:
	return _data.params[Raymarcher.PARAM_RADIUS].value


func set_radius(r: float):
	radius = r # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_RADIUS, r)


func get_height() -> float:
	return _data.params[Raymarcher.PARAM_HEIGHT].value


func set_height(h: float):
	height = h # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_HEIGHT, h)


func get_rounding() -> float:
	return _get_param(Raymarcher.PARAM_ROUNDING)


func set_rounding(r: float):
	rounding = r # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_ROUNDING, r)

