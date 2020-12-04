tool
extends "./sdf_item.gd"


export(float) var radius : float setget set_radius, get_radius


func _init():
	_data = SDF.SceneObject.new(SDF.SHAPE_SPHERE)


func get_radius() -> float:
	return _data.params[SDF.PARAM_RADIUS].value


func set_radius(r: float):
	radius = r # Useless but doing it anyways
	_set_param(SDF.PARAM_RADIUS, r)


