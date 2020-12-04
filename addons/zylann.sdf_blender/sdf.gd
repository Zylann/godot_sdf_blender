tool

# Constants and data classes

const SHAPE_SPHERE = 0
const SHAPE_BOX = 1
const SHAPE_TORUS = 2
const SHAPE_CYLINDER = 3

const OP_UNION = 0
const OP_SUBTRACT = 1
const OP_COLOR = 2

const PARAM_TRANSFORM = 0
const PARAM_COLOR = 1
const PARAM_SMOOTHNESS = 2
const PARAM_RADIUS = 3
const PARAM_SIZE = 4
const PARAM_THICKNESS = 5
const PARAM_HEIGHT = 6
const PARAM_ROUNDING = 7

const _param_names = [
	"transform",
	"color",
	"smoothness",
	"radius",
	"size",
	"thickness",
	"height",
	"rounding"
]

const _param_types = [
	TYPE_TRANSFORM,
	TYPE_COLOR,
	TYPE_REAL,
	TYPE_REAL,
	TYPE_VECTOR3,
	TYPE_REAL,
	TYPE_REAL,
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
				params[PARAM_ROUNDING] = Param.new(0.0)

			SHAPE_TORUS:
				params[PARAM_RADIUS] = Param.new(1.0)
				params[PARAM_THICKNESS] = Param.new(0.25)

			SHAPE_CYLINDER:
				params[PARAM_RADIUS] = Param.new(0.5)
				params[PARAM_HEIGHT] = Param.new(1.0)
				params[PARAM_ROUNDING] = Param.new(0.0)


static func get_param_type(param_index: int) -> int:
	return _param_types[param_index]


static func get_param_name(param_index: int) -> String:
	return _param_names[param_index]

