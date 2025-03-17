class_name Merge

## Set can_merge on all the cells of the first mergeable group
static func set_can_merge(cells, coords, mouse_tile, mergeable_cells: Array[Cell]):
	mergeable_cells.clear();
	
	if not coords.has(mouse_tile):
		return
	var first_cell: Cell = coords[mouse_tile]
	var kind = first_cell.kind
	var cell_list: Array[Cell] = cells.filter(func(cell): return cell.kind == kind)
	
	var merge_neighbourgs: Array[Cell] = []
	get_recursive_merge_neighbours(coords, first_cell, cell_list, merge_neighbourgs)
		
	if len(merge_neighbourgs) < Cell.NB_CELL_FOR_MERGE[kind]:
		return # not enought neighbourgs
	mergeable_cells.append(first_cell)
	for cell in merge_neighbourgs:
		mergeable_cells.append(cell)

static func get_recursive_merge_neighbours(coords, cell: Cell, cell_list: Array[Cell], merge_neighbourgs: Array[Cell], dbg_rec_level:= 0) :
	var new_cells = Utils.ALL_DIRECTION \
		.map(func(dir): return Utils.moved_in_dir(cell.center, dir)) \
		.filter(func(pos): return coords.has(pos) and cell_list.has(coords[pos])) \
		.map(func(pos): return coords[pos])

	var added_cells_to_check: Array[Cell] = []

	for new_cell in new_cells:
		cell_list.remove_at(cell_list.find(new_cell))
		merge_neighbourgs.push_back(new_cell)
		added_cells_to_check.push_back(new_cell)
		if len(merge_neighbourgs) >= Cell.NB_CELL_FOR_MERGE[cell.kind]:
			return

	for new_cell in added_cells_to_check:
		if len(merge_neighbourgs) >= Cell.NB_CELL_FOR_MERGE[cell.kind]:
			return
		get_recursive_merge_neighbours(
			coords,
			new_cell,
			cell_list,
			merge_neighbourgs,
			dbg_rec_level
		)
		if len(merge_neighbourgs) >= Cell.NB_CELL_FOR_MERGE[cell.kind]:
			return

"""
## Pour le type2, je dois detecter les enfants allentours, et voir leur parent
static func get_recursive_merge_neighbours_type2(coords, cell: Cell, cell_list: Array[Cell], merge_neighbourgs: Array[Cell], dbg_rec_level:= 0) :
	var new_cells_to_check: Array[Cell] = []
	for child in cell.childs:
		for dir in Utils.ALL_DIRECTION:
			var pos = Utils.moved_in_dir(child, dir)
			## avec le coords[pos], je get direct le parent, meme si je suis sur la pos de l'enfant
			if coords.has(pos) and cell_list.has(coords[pos]) and !new_cells_to_check.has(coords[pos]):
				new_cells_to_check.push_back(coords[pos])

	var added_cells_to_check: Array[Cell] = []

	for new_cell in new_cells_to_check:
		cell_list.remove_at(cell_list.find(new_cell))
		merge_neighbourgs.push_back(new_cell)
		added_cells_to_check.push_back(new_cell)
		if len(merge_neighbourgs) >= Cell.NB_CELL_FOR_MERGE[cell.kind]:
			return

	for new_cell in added_cells_to_check:
		if len(merge_neighbourgs) >= Cell.NB_CELL_FOR_MERGE[cell.kind]:
			return
		get_recursive_merge_neighbours_type2(
			coords,
			new_cell,
			cell_list,
			merge_neighbourgs,
			dbg_rec_level
		)
		if len(merge_neighbourgs) >= Cell.NB_CELL_FOR_MERGE[cell.kind]:
			return
"""
