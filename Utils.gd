class_name Utils

enum Direction { 
	TopLeft,
	TopRight,
	Left,
	Right,
	BottomLeft,
	BottomRight,
}

const ALL_DIRECTION: Array[Direction] = [
	Direction.TopLeft,
	Direction.TopRight,
	Direction.Left,
	Direction.Right,
	Direction.BottomLeft,
	Direction.BottomRight,
]

## angle as degree
static func vec_to_direction(vec: Vector2i) -> Direction:
	var angle = rad_to_deg(Vector2(vec).angle())
	angle = float(roundi(angle + 360) % 360) + 30
	if angle >= 0 and angle <= 60:
		return Direction.Right
	elif angle >= 60 and angle <= 120:
		return Direction.BottomRight
	elif angle >= 120 and angle <= 180:
		return Direction.BottomLeft
	elif angle >= 180 and angle <= 240:
		return Direction.Left
	elif angle >= 240 and angle <= 300:
		return Direction.TopLeft
	elif angle >= 300 and angle <= 360:
		return Direction.TopRight
	else:
		return Direction.Right


static func moved_in_dir(start: Vector2i, dir: Direction) -> Vector2i:
	match dir:
		Direction.TopLeft: 
			return start + Vector2i(start.y % 2 - 1, -1)
		Direction.TopRight: 
			return start + Vector2i(start.y % 2, -1)
		Direction.Left: 
			return start + Vector2i(-1, 0)
		Direction.Right: 
			return start + Vector2i(1, 0)
		Direction.BottomLeft: 
			return start + Vector2i(start.y % 2 - 1, 1)
		Direction.BottomRight: 
			return start + Vector2i(start.y % 2, 1)
	return Vector2i(0, 0) # TODO crash

static func cells_list_to_dict(base: Array[Cell]) -> Dictionary[Vector2i, Cell]:
	var result: Dictionary[Vector2i, Cell] = {}
	for cell in base:
		if cell.cell_type == Cell.CellType.TYPE1:
			result[cell.center] = cell
		else:
			pass # TODO logique de detetion de tous les tiles que rempli une grosse cell
	#print(result)
	return result
