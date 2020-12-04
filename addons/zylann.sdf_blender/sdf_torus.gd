tool
extends "./sdf_item.gd"


export(float) var radius : float setget set_radius, get_radius
export(float) var thickness : float setget set_thickness, get_thickness


func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_TORUS)


func get_radius() -> float:
	return _data.params[SDF.PARAM_RADIUS].value


func set_radius(r: float):
	radius = r # Useless but doing it anyways
	_set_param(SDF.PARAM_RADIUS, r)


func get_thickness() -> float:
	return _get_param(SDF.PARAM_THICKNESS)


func set_thickness(r: float):
	thickness = r # Useless but doing it anyways
	_set_param(SDF.PARAM_THICKNESS, r)

