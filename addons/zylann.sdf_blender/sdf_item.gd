@tool
extends Node3D

const SDF = preload("./sdf.gd")
const SDFContainer = preload("./sdf_container.gd")

@export_enum("Add", "Subtract", "Color") var operation :
	get:
		return _data.operation
	set(op):
		operation = op # Useless but doing it anyways
		if _container != null:
			_container.set_object_operation(_data, op)
		else:
			_data.operation = op
@export var color: Color = Color(1,1,1) :
	get:
		return _data.params[SDF.PARAM_COLOR].value
	set(col):
		color = col # Useless but doing it anyways
		_set_param(SDF.PARAM_COLOR, col)
@export var smoothness: float = 0.2 :
	get:
		return _data.params[SDF.PARAM_SMOOTHNESS].value
	set(s):
		s = clamp(s, 0.0, 1.0)
		smoothness = s # Useless but doing it anyways
		_set_param(SDF.PARAM_SMOOTHNESS, s)

var _data : SDF.SceneObject
var _container : SDFContainer


func _init():
	set_notify_transform(true) # requires valid gizmo




func _set_param(param_index: int, value):
	var param : Variant = _data.params[param_index]
	if _container != null:
		_container.set_object_param(_data, param_index, value)
	else:
		param.value = value

	if Engine.is_editor_hint() and is_inside_tree():
		# Not all params need to update gizmos, but it's ok for now.
		update_gizmos()


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


func _get_configuration_warnings() -> PackedStringArray :
	var msg : PackedStringArray = PackedStringArray()
	if _container == null:
		msg.append("This node must be child of a SDFContainer node.")
	return msg

