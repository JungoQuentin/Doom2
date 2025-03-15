class_name Cell

enum CellType{ TYPE1, TYPE2 }

const CELLS_N_FOR_TYPE2 = 7

var center: Vector2i;
var cell_type: CellType;
var childs: Array[Vector2i];
var can_merge: bool;

func _init(_center: Vector2i, _cell_type: CellType):
	self.center = _center;
	self.cell_type = _cell_type;
	self.childs = [];
	if cell_type == CellType.TYPE2:
		for i in range(6): self.childs.append(Utils.moved_in_dir(center, i));
	self.can_merge = false;
