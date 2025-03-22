class_name Cell

const NB_TYPES: int = 5

const NAMES: Array[String] = [
	"Cells",
	"Super Cells",
	"Factory Cells",
	"Special Cells",
]

const size: Array[float] = [
	1.35,
	3.8,
	6,
	8.2,
	10,
]

const color: Array[Color] = [
	Color.LIGHT_PINK,
	Color(1, 0.67, 0.62),
	Color(0.92, 0.67, 0.81),
	Color(0.5, 0.35, 0.88),
]

## Nombre de cellule qu'il faut fusionner pour passer au type suivant
const NB_CELL_FOR_MERGE: Array[int] = [
	12,
	6,
	10,
	5,
	1000,
]

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
