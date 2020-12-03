tool
#class_name RaymarcherItem
extends Spatial

const Raymarcher = preload("./raymarcher.gd")


export(int, "Add", "Subtract", "Color") var operation setget set_operation, get_operation
export(Color) var color = Color(1,1,1) setget set_color, get_color
export(float) var smoothness = 0.2 setget set_smoothness, get_smoothness

var _data : Raymarcher.SceneObject
var _raymarcher : Raymarcher


func _init():
	set_notify_transform(true)


func set_operation(op: int):
	operation = op # Useless but doing it anyways
	if _raymarcher != null:
		_raymarcher.set_object_operation(_data, op)
	else:
		_data.operation = op


func get_operation() -> int:
	return _data.operation


func set_color(col: Color):
	color = col # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_COLOR, col)


func get_color() -> Color:
	return _data.params[Raymarcher.PARAM_COLOR].value


func set_smoothness(s: float):
	s = clamp(s, 0.0, 1.0)
	smoothness = s # Useless but doing it anyways
	_set_param(Raymarcher.PARAM_SMOOTHNESS, s)


func get_smoothness() -> float:
	return _data.params[Raymarcher.PARAM_SMOOTHNESS].value


func _set_param(param_index: int, value):
	if _raymarcher != null:
		_raymarcher.set_object_param(_data, param_index, value)
	else:
		_data.params[param_index].value = value


func _get_param(param_index: int):
	return _data.params[param_index].value


# Used internally.
func get_raymarcher_data() -> Raymarcher.SceneObject:
	return _data


func _get_raymarcher() -> Raymarcher:
	var parent = get_parent()
	while parent != null and not (parent is Raymarcher):
		parent = parent.get_parent()
	return parent


func _set_raymarcher(rm: Raymarcher):
	if _raymarcher != null:
		_raymarcher.schedule_structural_update()
	_raymarcher = rm
	if _raymarcher != null:
		_raymarcher.schedule_structural_update()


func _notification(what: int):
	match what:
		NOTIFICATION_PARENTED:
			_set_raymarcher(_get_raymarcher())
		
		NOTIFICATION_UNPARENTED:
			_set_raymarcher(_get_raymarcher())
		
		NOTIFICATION_TRANSFORM_CHANGED:
			_set_param(Raymarcher.PARAM_TRANSFORM, global_transform.affine_inverse())
		
		# TODO Visibility?


func _get_configuration_warning() -> String:
	if _raymarcher == null:
		return "This node must be child of a Raymarcher node."
	return ""

