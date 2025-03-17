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
static func angle_to_direction(angle: float) -> Direction:
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
		if cell.kind == 0:
			result[cell.center] = cell
		elif cell.kind == 2:
			result[cell.center] = cell
			for child in cell.childs:
				result[child] = cell
		else:
			pass # TODO logique de detetion de tous les tiles que rempli une grosse cell
	return result


## Return a tile's position and its surroundings based on the kind of cell
static func get_surroundings(position: Vector2i, kind: int) -> Array[Vector2i]:
	var childs: Array[Vector2i] = [position]
	if kind >= 1:
		for dir in range(6): # first circle
			childs.append(moved_in_dir(position, dir))
	return childs


## Checks if any tile around a position is occipied
static func are_there_cells_around(position: Vector2i, coords: Dictionary[Vector2i, Cell], kind: int) -> bool:
	for gost_child in get_surroundings(position, kind):
		if coords.has(gost_child):
			return true
	return false

## Checks if any tile around a position is occipied by a higher kind of cell
static func are_there_bigger_or_same_cells_around(position: Vector2i, coords: Dictionary[Vector2i, Cell], kind: int, self_cell) -> bool:
	for gost_child in get_surroundings(position, kind):
		if coords.has(gost_child) and coords[gost_child].kind >= kind and coords[gost_child] != self_cell:
			return true
	return false
