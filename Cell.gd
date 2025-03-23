class_name Cell

const NB_TYPES: int = 5

const NAMES: Array[String] = [
	"Cells",
	"Super Cells",
	"Factory Cells",
	"Special Cells",
	"Super Factory Cells"
]

const size: Array[float] = [
	1.4,
	3.5,
	8.1,
	9.5,
	17.4,
]

const shape: Array = [
	[],
	[0],
	[2, 1],
	[3, 2, 1],
	[6, 4, 3, 2, 1, 1, 0]
]

const color: Array[Color] = [
	Color.LIGHT_PINK,
	Color(1, 0.67, 0.62),
	Color(0.92, 0.67, 0.81),
	Color(0.66, 0.64, 0.92),
	Color(1, 0.58, 0.72),
]

## Nombre de cellule qu'il faut fusionner pour passer au type suivant
const NB_CELL_FOR_MERGE: Array[int] = [1, 1, 1, 1, 2]
"""
[
	12,
	6,
	12,
	2,
	1000,
]"""

## Nombre de cellules à aparaitre au clique
const NB_SPAWN_CELL: Array[int] = [
	1,
	3,
	5,
	5,
	10,
]

var center: Vector2i
var kind: int  # Anciennement "cell_type"
var childs: Array[Vector2i]
var can_merge: bool
var rnd: Array[float]

func _init(_center: Vector2i, _kind: int):
	self.center = _center
	self.kind = _kind
	self.rnd = []
	for _i in range(4):
		self.rnd.append(randf())
	
	self.childs = Utils.get_surroundings(self.center, self.kind)
	self.can_merge = false

func _to_string() -> String:
	return "Cell[T" + str(self.kind) + " pos:" + str(self.center) + "]"
