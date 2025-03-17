class_name Cell

const size: Array[float] = [
	1.35,
	3.8,
	6,
	8,
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
	5,
	20,
];

## Nombre de cellules à aparaitre au clique
const NB_SPAWN_CELL: Array[int] = [
	1,
	3,
	5
];

var center: Vector2i;
var kind: int;  # Anciennement "cell_type"
var childs: Array[Vector2i];
var can_merge: bool;
var rnd: Array[float];

func _init(center: Vector2i, kind: int):
	self.center = center;
	self.kind = kind;
	self.rnd = [];
	for _i in range(4):
		self.rnd.append(randf());
	
	self.childs = [self.center];
	for i in range(kind):
		print(i)
	
	match kind:
		1:
			for i in range(6):
				self.childs.append(Utils.moved_in_dir(center, i));
		2:
			for i in range(6):  # first circle
				var first_circle = Utils.moved_in_dir(center, i);
				self.childs.append(first_circle);
			for i in range(6):  # second circle
				var first_circle = Utils.moved_in_dir(center, i);
				for j in range(3):
					var new_child = Utils.moved_in_dir(first_circle, (i + j) % 6)
					if not (new_child in self.childs) and new_child != center:
						self.childs.append(new_child)
		_: pass
	self.can_merge = false;

func _to_string() -> String:
	return "Cell(T" + str(self.kind) + " " + str(self.center) + ")"
