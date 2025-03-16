class_name Cell

enum CellType { TYPE1, TYPE2, TYPE3, TYPE4 }

## Nombre de cellule qu'il faut pour passer au type suivant
const N_CELL_FOR_TYPE: Dictionary[int, int] = {
	CellType.TYPE1: 3,
	CellType.TYPE2: 3,
	CellType.TYPE3: 3,
	CellType.TYPE4: 3,
}

var center: Vector2i;
var cell_type: CellType;
var childs: Array[Vector2i];
var can_merge: bool;

func _init(_center: Vector2i, _cell_type: CellType):
	self.center = _center;
	self.cell_type = _cell_type;
	self.childs = [];
	if cell_type == CellType.TYPE2:
		for i in range(6):
			self.childs.append(Utils.moved_in_dir(center, i));
	if cell_type == CellType.TYPE3:
		for i in range(6):  # first circle
			var first_circle = Utils.moved_in_dir(center, i);
			self.childs.append(first_circle);
		for i in range(6):  # second circle
			var first_circle = Utils.moved_in_dir(center, i);
			for j in range(3):
				var new_child = Utils.moved_in_dir(first_circle, (i + j) % 6)
				if not (new_child in self.childs) and new_child != center:
					self.childs.append(new_child)
	self.can_merge = false;

func _to_string() -> String:
	var type = "unknown"
	match self.cell_type:
		CellType.TYPE1:
			type = "T1"
		CellType.TYPE2:
			type = "T2"
		CellType.TYPE3:
			type = "T3"
	
	return type + " " + str(self.center)
