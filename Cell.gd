class_name Cell

enum CellType{ TYPE1, TYPE2 }

var center: Vector2i;
var cell_type: CellType;
var childs: Array[Vector2i];

func _init(center: Vector2i, cell_type: CellType):
	self.center = center;
	self.cell_type = cell_type;
	self.childs = [];
	if cell_type == CellType.TYPE2:
		for i in range(6): self.childs.append(center + Utils.vec_from_dir(i));
