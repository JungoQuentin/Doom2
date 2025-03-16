class_name Doom2
extends Node2D

const CENTER:= Vector2i(1_000, 1_000)
const TIME_BETWEEN_MULTIPLE_SPAWN = 0.05
const hex_ratio: float = 2/sqrt(3);
const h: float = 50.0; # Cell size
const overh_type1: float = 1.35;
const overh_type2: float = 1.25 * 3;
const overh_type3: float = 1.3 * 4.5;
const overh_type4: float = 1.3 * 4.5;
const cam_smoothing: float = 0.005;

const type1_color: Color = Color.LIGHT_PINK;
var type2_color: Color = Color.LIGHT_SALMON.lerp(Color.LIGHT_PINK, 0.5);
var type3_color: Color = Color.PLUM.lerp(Color.LIGHT_PINK, 0.5);
var type4_color: Color = Color.GREEN.lerp(Color.LIGHT_PINK, 0.5);

# Number of type1 cells spawned from type2 cell
const nb_type2_spawn: int = 3;
const nb_type3_spawn: int = 5;

# Stores the coods (Vec2) of every filled tile
var coords: Dictionary[Vector2i, Cell]
# List of the type (int) and center coords (Vec2) of cells
# order matters for rendering
var cells: Array[Cell] = [Cell.new(CENTER, Cell.CellType.TYPE1)];
# Coords of the tile under the mouse cursor
var mouse_tile: Vector2i;

var b: float = 0.0;

func _ready() -> void:
	$Camera2D.position = tile_to_pos(CENTER);
	coords = Utils.cells_list_to_dict(cells)
	start_auto_move_to_center()
	start_factories()


func _process(delta: float) -> void:
	b += delta;
	queue_redraw()
	
	if cells.is_empty(): return
	var cell_centers = cells.map(func(cell): return cell.center);
	# Move cam to center of mass
	var tot = cell_centers.reduce(func sum(accum, number): return accum + number, Vector2i.ZERO);
	$Camera2D.position = $Camera2D.position * (1 - cam_smoothing) + tile_to_pos(tot / len(cells)) * cam_smoothing;
	# Zoom cam to see all
	var cells_y = cell_centers.map(func(pos): return pos.y);
	var zoom = max(1, (cells_y.max() - cells_y.min()) * h / 600);
	$Camera2D.zoom = $Camera2D.zoom * (1 - cam_smoothing) + Vector2.ONE / zoom * cam_smoothing;


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		mouse_tile = pos_to_tile(get_global_mouse_position());
		if coords.has(mouse_tile):
			var cell = coords[mouse_tile];
			if cell.can_merge:
				merge(cell.cell_type)
			elif cell.cell_type == Cell.CellType.TYPE1:
				spawn_cell(mouse_tile)
			elif cell.cell_type == Cell.CellType.TYPE2:
				spawn_many(nb_type2_spawn)
			elif cell.cell_type == Cell.CellType.TYPE3:
				spawn_many(nb_type3_spawn)
			elif cell.cell_type == Cell.CellType.TYPE4:
				print('set')
			set_can_merge()
	if event is InputEventMouseMotion:
		var new_mouse_tile = pos_to_tile(get_global_mouse_position());
		if new_mouse_tile != mouse_tile:
			mouse_tile = new_mouse_tile;
			set_can_merge()


func spawn_many(q: int) -> void:
	for _i in range(q):
		await get_tree().create_timer(TIME_BETWEEN_MULTIPLE_SPAWN).timeout
		spawn_cell(mouse_tile)


func _draw() -> void:
	"""
	for i in range(980, 1020):
		for j in range(980, 1020):
			var pos = tile_to_pos(Vector2i(i, j))
			draw_circle(pos, h/2, Color.PALE_VIOLET_RED.lightened(0.6), false, 2)
	"""
	for cell in cells:
		var pos = tile_to_pos(cell.center)
		var color
		var overh
		var offset
		if cell.cell_type == Cell.CellType.TYPE1:
			color = type1_color
			overh = overh_type1
			offset = 4 * Vector2(sin(2 * b + 0.3) - cos(b + 0.1), cos(b) - sin(1.5 * b + 0.8))
		elif cell.cell_type == Cell.CellType.TYPE2:
			color = type2_color
			overh = overh_type2
			offset = 4 * Vector2(sin(1.5 * b + 0.6) - cos(b*2 + 0.3), cos(b) - sin(1.5 * b + 0.5))
		elif cell.cell_type == Cell.CellType.TYPE3:
			color = type3_color
			overh = overh_type3
			offset = 4 * Vector2(sin(2 * b + 0.1) - cos(b + 0.2), cos(b) - sin(3.5 * b + 0.2))
		elif cell.cell_type == Cell.CellType.TYPE4:
			# TODO check
			color = type4_color
			overh = overh_type4
			offset = 4 * Vector2(sin(2 * b + 0.1) - cos(b + 0.2), cos(b) - sin(3.5 * b + 0.2))
		
		var col = color
		if cell.can_merge or cell.center == mouse_tile or mouse_tile in cell.childs:
			col = color.darkened(0.1)
		
		
		draw_circle(pos, h/2 * overh, col, true)
		draw_circle(pos, h/2 * overh, color.darkened(0.1), false, 3)
		draw_circle(pos + offset, h/8 * overh, color.darkened(0.15), true)
	"""
	for coord in coords: # DEBUG
		var cell_type = coords[coord].cell_type
		var col
		if cell_type == Cell.CellType.TYPE1:
			col = Color.BEIGE
		elif cell_type == Cell.CellType.TYPE2:
			col = Color.SADDLE_BROWN
		else:
			col = Color.DODGER_BLUE
		draw_circle(tile_to_pos(coord), h/8, col, true)
	"""
	# draw_circle(tile_to_pos(mouse_tile), h/2 * overh, Color.INDIAN_RED, false, 3)


func start_factories() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0 # une cellule type1 toutes les 2 secondes
	timer.timeout.connect(factory)
	timer.autostart = true
	timer.start()


func factory():
	for cell in cells.duplicate():
		if cell.cell_type == Cell.CellType.TYPE3:
			await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
			spawn_cell(cell.center)
		elif cell.cell_type == Cell.CellType.TYPE4:
			await get_tree().create_timer(randf_range(0.01, 0.01)).timeout
			spawn_cell(cell.center)


func merge(type: Cell.CellType) -> void:
	var mergeable_cells: Array[Cell] = cells.filter(func(cell): return cell.can_merge and cell.cell_type == type)

	for cell in mergeable_cells:
		match type:
			Cell.CellType.TYPE1:
				coords.erase(cell.center)
				cells.remove_at(cells.find(cell))
				$PopT2.play()
			Cell.CellType.TYPE2:
				for child in cell.childs:
					coords.erase(child)
				coords.erase(cell.center)
				cells.remove_at(cells.find(cell))
				$PopT3.play()
			Cell.CellType.TYPE3:
				for child in cell.childs:
					coords.erase(child)
				coords.erase(cell.center)
				cells.remove_at(cells.find(cell))
				$PopT3.play()
		
	for cell in mergeable_cells:
		if not Utils.are_there_bigger_cells_around(cell.center, coords, cell.cell_type, cell):
			var new_cell = Cell.new(cell.center, cell.cell_type + 1)
			for child in new_cell.childs:
				if coords.has(child) and coords[child].cell_type == Cell.CellType.TYPE1:
					cells.remove_at(cells.find(coords[child]))
					coords.erase(child)
			coords[cell.center] = new_cell;
			for cell_child in new_cell.childs:
				coords[cell_child] = new_cell;
			if cells.is_empty():
				cells.append(new_cell);
				return
			var place_to_insert = 1;
			if len(cells) > 1:
				place_to_insert = randi() % (len(cells) - 1) + 1;
			cells.insert(place_to_insert, new_cell);
			return


func spawn_cell(source_coords: Vector2i):
	var spawn_dir = randi() % 6; # Choose 1 of 6 random directions (spawn_dir)
	var current_center = source_coords;
	$PopT1.play()
	while true:
		for i in range(6):
			var check_tile = Utils.moved_in_dir(current_center, (spawn_dir + i) % 6);
			if not coords.has(check_tile):
				var new_cell = Cell.new(check_tile, Cell.CellType.TYPE1)
				coords[check_tile] = new_cell;
				var place_to_insert = 1;
				if len(cells) > 1:
					place_to_insert = randi() % (len(cells) - 1) + 1;
				cells.insert(place_to_insert, new_cell);
				return
		current_center = Utils.moved_in_dir(current_center, spawn_dir);

func pos_to_tile(pos: Vector2) -> Vector2i:
	var odd = int(pos.y / h - 0.5) % 2
	return Vector2i((pos.x / h / hex_ratio + 0.08 + odd*0.37), (pos.y / h) + 0.5)

func tile_to_pos(tile_coords: Vector2i) -> Vector2:
	var odd = tile_coords.y % 2;
	return h * Vector2(hex_ratio * tile_coords.x + odd * 0.5, tile_coords.y)


## Lance la logique de deplacement automatique vers le centre
## Un timer qui run toutes les x secondes
func start_auto_move_to_center() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.05
	timer.timeout.connect(func(): cells.map(func(cell): try_to_move_to_center(cell)))
	timer.autostart = true
	timer.start()

## Bouge une cellule vers sa new_position
func move_cell(cell: Cell, dir: Utils.Direction) -> void:
	var new_position = Utils.moved_in_dir(cell.center, dir)
	if cell.cell_type == Cell.CellType.TYPE1:
		coords.erase(cell.center)
		coords[new_position] = cell
		cell.center = new_position
	elif cell.cell_type == Cell.CellType.TYPE2:
		for child in cell.childs:
			coords.erase(child)
			var shifted_child = Utils.moved_in_dir(child, dir)
			if coords.has(shifted_child) and coords[shifted_child].cell_type == Cell.CellType.TYPE1:
				cells.remove_at(cells.find(coords[shifted_child]))
				coords.erase(shifted_child)
		coords.erase(cell.center)
		coords[new_position] = cell
		cell.center = new_position
		for child in cell.childs:
			coords[Utils.moved_in_dir(child, dir)] = cell
		for i in range(6):
			cell.childs[i] = Utils.moved_in_dir(cell.childs[i], dir)
	elif cell.cell_type == Cell.CellType.TYPE3:
		for child in cell.childs:
			coords.erase(child)
			var shifted_child = Utils.moved_in_dir(child, dir)
			if coords.has(shifted_child) and coords[shifted_child].cell_type == Cell.CellType.TYPE1:
				cells.remove_at(cells.find(coords[shifted_child]))
				coords.erase(shifted_child)
		coords.erase(cell.center)
		coords[new_position] = cell
		cell.center = new_position
		for child in cell.childs:
			coords[Utils.moved_in_dir(child, dir)] = cell
		for i in range(18):
			cell.childs[i] = Utils.moved_in_dir(cell.childs[i], dir)
	elif cell.cell_type == Cell.CellType.TYPE4:
		pass # TODO move_cell

## Bouge une cellule vers le centre si possible
func try_to_move_to_center(cell: Cell) -> void:
	if cell.center == CENTER:
		return
	var angle = rad_to_deg(Vector2(CENTER - cell.center).angle());
	angle += (randf() - 0.5) * 90;
	var direction = Utils.angle_to_direction(angle);

	if cell.cell_type == Cell.CellType.TYPE1:
		var new_position = Utils.moved_in_dir(cell.center, direction)
		if !coords.has(new_position) and len(cells) > 4:
			move_cell(cell, direction)
	elif cell.cell_type == Cell.CellType.TYPE2:
		var new_position = Utils.moved_in_dir(cell.center, direction)
		if not Utils.are_there_bigger_cells_around(new_position, coords, cell.cell_type - 1, cell):
			move_cell(cell, direction)
	elif cell.cell_type == Cell.CellType.TYPE3:
		var new_position = Utils.moved_in_dir(cell.center, direction)
		if not Utils.are_there_bigger_cells_around(new_position, coords, cell.cell_type - 1, cell):
			move_cell(cell, direction)
	elif cell.cell_type == Cell.CellType.TYPE4:
		var new_position = Utils.moved_in_dir(cell.center, direction)
		if not Utils.are_there_bigger_cells_around(new_position, coords, cell.cell_type - 1, cell):
			move_cell(cell, direction)
	
## Set can_merge on all the cells of the first mergeable group
func set_can_merge():
	for cell in cells:
		cell.can_merge = false
	if not coords.has(mouse_tile):
		return
	var first_cell: Cell = coords[mouse_tile]
	var type = first_cell.cell_type
	var cell_list: Array[Cell] = cells.filter(func(cell): return cell.cell_type == type)
	
	var merge_neighbourgs: Array[Cell] = []
	match type:
		Cell.CellType.TYPE1:
			get_recursive_merge_neighbours(first_cell, cell_list, merge_neighbourgs)
		Cell.CellType.TYPE2:
			get_recursive_merge_neighbours_type2(first_cell, cell_list, merge_neighbourgs)
		Cell.CellType.TYPE3:
			get_recursive_merge_neighbours_type2(first_cell, cell_list, merge_neighbourgs)
		
	if len(merge_neighbourgs) + 1 < Cell.N_CELL_FOR_TYPE[type]:
		return # not enought neighbourgs
	first_cell.can_merge = true
	for cell in merge_neighbourgs:
		cell.can_merge = true

func get_recursive_merge_neighbours(cell: Cell, cell_list: Array[Cell], merge_neighbourgs: Array[Cell], dbg_rec_level:= 0) :
	var new_cells = Utils.ALL_DIRECTION \
		.map(func(dir): return Utils.moved_in_dir(cell.center, dir)) \
		.filter(func(pos): return coords.has(pos) and cell_list.has(coords[pos])) \
		.map(func(pos): return coords[pos])

	var added_cells_to_check: Array[Cell] = []

	for new_cell in new_cells:
		cell_list.remove_at(cell_list.find(new_cell))
		merge_neighbourgs.push_back(new_cell)
		added_cells_to_check.push_back(new_cell)
		if len(merge_neighbourgs) + 1 >= Cell.N_CELL_FOR_TYPE[cell.cell_type]:
			return

	for new_cell in added_cells_to_check:
		if len(merge_neighbourgs) + 1 >= Cell.N_CELL_FOR_TYPE[cell.cell_type]:
			return
		get_recursive_merge_neighbours(
			new_cell,
			cell_list,
			merge_neighbourgs,
			dbg_rec_level + 1
		)
		if len(merge_neighbourgs) + 1 >= Cell.N_CELL_FOR_TYPE[cell.cell_type]:
			return

## Pour le type2, je dois detecter les enfants allentours, et voir leur parent
func get_recursive_merge_neighbours_type2(cell: Cell, cell_list: Array[Cell], merge_neighbourgs: Array[Cell], dbg_rec_level:= 0) :
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
		if len(merge_neighbourgs) + 1 >= Cell.N_CELL_FOR_TYPE[cell.cell_type]:
			return

	for new_cell in added_cells_to_check:
		if len(merge_neighbourgs) + 1 >= Cell.N_CELL_FOR_TYPE[cell.cell_type]:
			return
		get_recursive_merge_neighbours_type2(
			new_cell,
			cell_list,
			merge_neighbourgs,
			dbg_rec_level + 1
		)
		if len(merge_neighbourgs) + 1 >= Cell.N_CELL_FOR_TYPE[cell.cell_type]:
			return
