class_name Cell

enum CellType{ TYPE1, TYPE2 }

var center: Vector2i;
var cell_type: CellType;
func _init(center: Vector2i, cell_type: CellType):
	self.center = center;
	self.cell_type = cell_type;
