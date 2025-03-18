class_name Merge

## Returns a list of mergeable cells around the mouse tile
static func set_can_merge(coords, mouse_tile) -> Array[Cell]:
	if not coords.has(mouse_tile):
		return []
	
	var first_cell: Cell = coords[mouse_tile]
	var kind = first_cell.kind
	
	var mergeable_cells: Array[Cell] = [first_cell]
	for _i in range(Cell.NB_CELL_FOR_MERGE[kind] - 1):
		var new_neibourg = get_new_neibourg(coords, mergeable_cells, kind)
		if new_neibourg == null:
			return []
		mergeable_cells.append(new_neibourg)
	return mergeable_cells

static func get_new_neibourg(coords, mergeable_cells, kind) -> Cell:
	mergeable_cells.shuffle()
	for mergeable_cell in mergeable_cells:
		var neibourgs = Utils.get_neibourgs(mergeable_cell.center, kind)
		for neibourg in neibourgs:
			if coords.has(neibourg):
				var neibourg_cell = coords[neibourg]
				if neibourg_cell.kind == kind and neibourg_cell not in mergeable_cells:
					return neibourg_cell
	return
