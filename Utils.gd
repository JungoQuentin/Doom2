class_name Utils

enum Direction {
	Right,
	BottomRight,
	BottomLeft,
	Left,
	TopLeft,
	TopRight,
}

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
	printerr("moved_in_dir() had a bad 'dir' argument: ()", dir, "Should be between 1 and 6")
	return Vector2i.ZERO


static func cells_list_to_dict(cells: Array) -> Dictionary[Vector2i, Cell]:
	var coords: Dictionary[Vector2i, Cell] = {}
	for cells_of_kind in cells:
		for cell in cells_of_kind:
			for child in cell.childs:
				coords[child] = cell
	return coords



## Return a tile's position and its surroundings (gost childs) based on the kind of cell
static func get_surroundings(position: Vector2i, kind: int) -> Array[Vector2i]:
	var childs: Array[Vector2i] = [position]
	for dir in range(6):
		var mov = position
		for shape in Cell.shape[kind]:
			mov = moved_in_dir(mov, dir)
			childs.append(mov)
			var mov_r = moved_in_dir(mov, (dir + 1) % 6)
			for n in range(shape):
				childs.append(mov_r)
				mov_r = moved_in_dir(mov_r, (dir + 1) % 6)
	return childs

## Return a tile's neibourgs positions (touching surroundings) based on the kind of cell
static func get_neibourgs(position: Vector2i, kind: int) -> Array[Vector2i]:
	var neibourgs: Array[Vector2i] = []
	match kind:
		0:
			for dir in range(6): # first circle
				neibourgs.append(moved_in_dir(position, dir))
		_: # TODO make more efficient
			var childs = get_surroundings(position, kind)
			for child in childs:
				for dir in range(6):
					neibourgs.append(moved_in_dir(child, dir))
			for child in childs:
				if child in neibourgs:
					while neibourgs.has(child):
						neibourgs.erase(child)
	return neibourgs

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
