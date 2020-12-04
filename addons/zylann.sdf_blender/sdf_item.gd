tool
extends Spatial

const SDF = preload("./sdf.gd")
const SDFContainer = preload("./sdf_container.gd")


export(int, "Add", "Subtract", "Color") var operation setget set_operation, get_operation
export(Color) var color = Color(1,1,1) setget set_color, get_color
export(float) var smoothness = 0.2 setget set_smoothness, get_smoothness

var _data : SDF.SceneObject
var _container : SDFContainer


func _init():
	set_notify_transform(true)


func set_operation(op: int):
	operation = op # Useless but doing it anyways
	if _container != null:
		_container.set_object_operation(_data, op)
	else:
		_data.operation = op


func get_operation() -> int:
	return _data.operation


func set_color(col: Color):
	color = col # Useless but doing it anyways
	_set_param(SDF.PARAM_COLOR, col)


func get_color() -> Color:
	return _data.params[SDF.PARAM_COLOR].value


func set_smoothness(s: float):
	s = clamp(s, 0.0, 1.0)
	smoothness = s # Useless but doing it anyways
	_set_param(SDF.PARAM_SMOOTHNESS, s)


func get_smoothness() -> float:
	return _data.params[SDF.PARAM_SMOOTHNESS].value


func _set_param(param_index: int, value):
	var param : SDF.Param = _data.params[param_index]

	if _container != null:
		_container.set_object_param(_data, param_index, value)
	else:
		param.value = value

	if Engine.editor_hint and is_inside_tree():
		# Not all params need to update gizmos, but it's ok for now.
		update_gizmo()


func _get_param(param_index: int):
	return _data.params[param_index].value


# Used internally.
func get_sdf_scene_object() -> SDF.SceneObject:
	return _data


func _get_container() -> SDFContainer:
	var parent = get_parent()
	while parent != null and not (parent is SDFContainer):
		parent = parent.get_parent()
	return parent


func _set_container(rm: SDFContainer):
	if _container != null:
		_container.schedule_structural_update()
	_container = rm
	if _container != null:
		_container.schedule_structural_update()


func _notification(what: int):
	match what:
		NOTIFICATION_PARENTED:
			_set_container(_get_container())
		
		NOTIFICATION_UNPARENTED:
			_set_container(_get_container())
		
		NOTIFICATION_TRANSFORM_CHANGED:
			_set_param(SDF.PARAM_TRANSFORM, global_transform.affine_inverse())
		
		# TODO Visibility?


func _get_configuration_warning() -> String:
	if _container == null:
		return "This node must be child of a SDFContainer node."
	return ""

