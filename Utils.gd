class_name Utils

enum Direction { TopLeft, TopRight, Left, Right, BottomLeft, BottomRight }

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

static func top_left(from: Vector2i) -> Vector2i:
	return Vector2i(from.x, from.y - 1)
static func top_right(from: Vector2i) -> Vector2i:
	return Vector2i(from.x + 1, from.y - 1)
static func left(from: Vector2i) -> Vector2i:
	return Vector2i(from.x - 1, from.y)
static func right(from: Vector2i) -> Vector2i:
	return Vector2i(from.x + 1, from.y)
static func bottom_left(from: Vector2i) -> Vector2i:
	return Vector2i(from.x, from.y + 1)
static func bottom_right(from: Vector2i) -> Vector2i:
	return Vector2i(from.x + 1, from.y + 1)

static func cells_list_to_dict(base: Array[Cell]) -> Dictionary[Vector2i, Cell.CellType]:
	var result: Dictionary[Vector2i, Cell.CellType] = {}
	for cell in base:
		if cell.cell_type == Cell.CellType.TYPE1:
			result[cell.center] = cell.cell_type
		else:
			pass # TODO logique de detetion de tous les tiles que rempli une grosse cell
	#print(result)
	return result
