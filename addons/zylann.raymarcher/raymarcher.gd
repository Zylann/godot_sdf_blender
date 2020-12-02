tool
#class_name Raymarcher
extends MeshInstance

const SHADER_PATH = "res://addons/zylann.raymarcher/raymarch.shader"

const SHAPE_SPHERE = 0
const SHAPE_BOX = 1
const SHAPE_TORUS = 2

const OP_UNION = 0
const OP_SUBTRACT = 1

const PARAM_TRANSFORM = 0
const PARAM_COLOR = 1
const PARAM_SMOOTHNESS = 2
const PARAM_RADIUS = 3
const PARAM_SIZE = 4
const PARAM_THICKNESS = 5

const _param_names = [
	"transform",
	"color",
	"smoothness",
	"radius",
	"size",
	"thickness"
]

const _param_types = [
	TYPE_TRANSFORM,
	TYPE_COLOR,
	TYPE_REAL,
	TYPE_REAL,
	TYPE_VECTOR3,
	TYPE_REAL
]

class Param:
	var value = null
	var uniform := ""

	func _init(p_v):
		value = p_v


class SceneObject:
	var operation := OP_UNION
	var shape := SHAPE_SPHERE
	var params := {}
	#var active := true

	func _init(p_shape: int):
		shape = p_shape

		params[PARAM_TRANSFORM] = Param.new(Transform())
		params[PARAM_COLOR] = Param.new(Color(1,1,1))
		params[PARAM_SMOOTHNESS] = Param.new(0.2)

		match shape:
			SHAPE_SPHERE:
				params[PARAM_RADIUS] = Param.new(1.0)
			SHAPE_BOX:
				params[PARAM_SIZE] = Param.new(Vector3(1,1,1))
			SHAPE_TORUS:
				params[PARAM_RADIUS] = Param.new(1.0)
				params[PARAM_THICKNESS] = Param.new(0.25)


class ShaderTemplate:
	var before_uniforms := ""
	var after_uniforms_before_scene := ""
	var after_scene := ""


var _objects := []
var _next_id := 0
var _shader_template : ShaderTemplate
var _shader_material : ShaderMaterial
var _need_shader_update := true


func _ready():
	_shader_template = _load_shader_template(SHADER_PATH)
	
	var pm := QuadMesh.new()
	pm.size = Vector2(2, 2)
	mesh = pm


static func get_param_type(param_index) -> int:
	return _param_types[param_index]


static func get_param_name(param_index) -> int:
	return _param_names[param_index]


func add_object(so: SceneObject, index: int):
	assert(not (so in _objects))
	_objects.insert(index, so)
	_need_shader_update = true


func remove_object(so: SceneObject):
	_objects.erase(so)
	_need_shader_update = true


func set_object_param(so: SceneObject, param_index: int, value):
	var param = so.params[param_index]
	if param.value != value:
		param.value = value
		if param.uniform != "" and _shader_material != null:
			_shader_material.set_shader_param(param.uniform, param.value)


func set_object_operation(so: SceneObject, op: int):
	if so.operation != op:
		so.operation = op
		_need_shader_update = true


func _process(delta):
	if _need_shader_update:
		_need_shader_update = false
		_update_shader()


func _update_shader():
	var shader : Shader
	if _shader_material == null:
		shader = Shader.new()
	else:
		shader = _shader_material.shader

	# I want to reset all material params but Godot does not have an API for that,
	# so I just create a new material
	_shader_material = ShaderMaterial.new()

	var code := _generate_shader_code(_objects, _shader_template)
	# TODO This is for debugging
	_debug_dump_text_file("generated_shader.txt", code)

	shader.code = code
	_shader_material.shader = shader
	material_override = _shader_material

	_update_material()


func _update_material():
	for obj in _objects:
		for param_index in obj.params:
			var param = obj.params[param_index]
			if param.uniform != "":
				_shader_material.set_shader_param(param.uniform, param.value)


static func _load_shader_template(fpath: String) -> ShaderTemplate:
	var f := File.new()
	var err := f.open(fpath, File.READ)
	if err != OK:
		push_error("Could not load {0}: error {1}".format([fpath, err]))
		return null
	var template := ShaderTemplate.new()
	var tags := [
		"//<uniforms>",
		"//</uniforms>",
		"//<scene>",
		"//</scene>"
	]
	var tag_index := 0
	while not f.eof_reached():
		var line := f.get_line()
		if tag_index < len(tags) and line.find(tags[tag_index]) != -1:
			tag_index += 1
			continue
		if tag_index % 2 == 0:
			line += "\n"
			match tag_index / 2:
				0:
					template.before_uniforms += line
				1:
					template.after_uniforms_before_scene += line
				2:
					template.after_scene += line
	f.close()
	return template


static func _make_uniform_name(index: int, name: String) -> String:
	return str("u_shape", index, "_", name)


static func _get_param_code(so: SceneObject, param_index: int) -> String:
	var param = so.params[param_index]
	if param.uniform != "":
		return param.uniform
	return str(param.value)


static func _godot_type_to_shader_type(type: int):
	match type:
		TYPE_REAL:
			return "float"
		TYPE_COLOR:
			return "vec4"
		TYPE_TRANSFORM:
			return "mat4"
		TYPE_VECTOR3:
			return "vec3"
		_:
			assert(false)


static func _get_shape_code(obj: SceneObject, pos_code: String) -> String:
	match obj.shape:
		SHAPE_SPHERE:
			return str(
				"get_sphere(", pos_code, ", vec3(0.0), ", _get_param_code(obj, PARAM_RADIUS), ")")

		SHAPE_BOX:
			return str("get_box(", pos_code, ", ", _get_param_code(obj, PARAM_SIZE), ")")

		SHAPE_TORUS:
			return str("get_torus(", pos_code, 
				", vec2(", _get_param_code(obj, PARAM_RADIUS), 
				", ", _get_param_code(obj, PARAM_THICKNESS), "))")
		_:
			assert(false)
	return ""


static func _generate_shader_code(objects : Array, template: ShaderTemplate) -> String:
	var uniforms := ""
	var scene := ""

	for object_index in len(objects):
		var obj : SceneObject = objects[object_index]
		#if not obj.active:
		#	continue

		# Note: the amount of uniforms in a shader is not unlimited.
		# There is a point the driver will say "no", depending on the graphics card.
		# In the future, if more shapes are needed within one container,
		# we could "freeze" some of the params and make them consts instead of uniforms
		
		for param_index in obj.params:
			var param = obj.params[param_index]
			param.uniform = _make_uniform_name(object_index, _param_names[param_index])
			var stype = _godot_type_to_shader_type(_param_types[param_index])
			uniforms += str("uniform ", stype, " ", param.uniform, ";\n")

		var pos_code := str("(", _get_param_code(obj, PARAM_TRANSFORM), " * vec4(p, 1.0)).xyz")
		var indent = "\t"
		
		var shape_code := _get_shape_code(obj, pos_code)
		
		match obj.operation:
			OP_UNION:
				scene += str(indent, "s = smooth_union_c(s.w, ", shape_code, ", s.rgb, ",
					_get_param_code(obj, PARAM_COLOR), ".rgb, ", 
					_get_param_code(obj, PARAM_SMOOTHNESS), ");\n")
			OP_SUBTRACT:
				scene += str(indent, "s = smooth_subtract_c(s.w, ", shape_code, ", s.rgb, ",
					_get_param_code(obj, PARAM_COLOR), ".rgb, ", 
					_get_param_code(obj, PARAM_SMOOTHNESS), ");\n")
				pass
			_:
				assert(false)

	return str(
		template.before_uniforms, 
		uniforms, 
		template.after_uniforms_before_scene, 
		scene, 
		template.after_scene)


static func _debug_dump_text_file(fpath: String, text: String):
	var f = File.new()
	var err = f.open(fpath, File.WRITE)
	if err != OK:
		push_error("Could not save file {0}: error {1}".format([fpath, err]))
		return
	f.store_string(text)
	f.close()


