class_name Cell

const NB_TYPES: int = 5

const NAMES: Array[String] = [
	"Cells",
	"Super Cells",
	"Factory Cells",
	"Special Cells",
	"Super Factory Cells"
]

const INSTANCE_COUNT: Array[int] = [
	10_000,
	10_000,
	5000,
	2000,
	500,
]

## Nombre de cellule qu'il faut fusionner pour passer au type suivant
const NB_CELL_FOR_MERGE: Array[int] = [ #[1, 1, 1, 1, 2]
	2, # 12
	2, # 6
	2, # 12
	2, # 5,
	2, # 15,
]

## Nombre de cellules à aparaitre au clique
const NB_SPAWN_CELL: Array[int] = [
	1,
	3,
	5,
	5,
	10,
]

const SHAPE: Array = [
	[],
	[1],
	[3, 2],
	[4, 3, 2],
	[7, 5, 4, 3, 2, 2, 1]
]

const CONTOUR: Array = [
	[[0]],
	[[1], [0]],
	[[3], [2], [1, 0]],
	[[4], [3], [2], [1, 0]],
	[[7], [6, 5], [4], [3], [2], [2], [1], [0]]
]

const SIZE: Array[float] = [
	1.4,
	3.5,
	8.1,
	9.5,
	17.4,
]

const COLOR: Array[Color] = [
	Color.LIGHT_PINK,
	Color(1, 0.67, 0.62),
	Color(0.92, 0.67, 0.81),
	Color(0.66, 0.64, 0.92),
	Color(1, 0.58, 0.72),
]

var center: Vector2i
var kind: int  # Anciennement "cell_type"
var childs: Array[Vector2i]
var can_merge: bool
var rot_dir: float # -1 or +1
var t: float = 0

func _init(_center: Vector2i, _kind: int):
	self.center = _center
	self.kind = _kind
	self.rot_dir = (randi_range(0, 1) - 0.5) * 2	
	self.childs = Utils.get_childs(self.center, self.kind)
	self.can_merge = false

func _to_string() -> String:
	return "Cell[T" + str(self.kind) + " pos:" + str(self.center) + "]"
