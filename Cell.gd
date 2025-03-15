class_name Cell

enum CellType{ TYPE1, TYPE2 }

const CELLS_N_FOR_TYPE2 = 7

var center: Vector2i;
var cell_type: CellType;
var can_merge: bool;

func _init(center: Vector2i, cell_type: CellType):
	self.center = center;
	self.cell_type = cell_type;
	self.can_merge = false;
