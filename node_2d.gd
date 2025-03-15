extends Node2D

const CENTER:= Vector2i(1_000, 1_000)
const hex_ratio: float = 2/sqrt(3);
const h: float = 50.0; # Cell size
const overh: float = 1.33;
const cam_smoothing: float = 0.002;

const type1_color: Color = Color.LIGHT_PINK;
const type2_color: Color = Color.LIGHT_SALMON;

# Number of type1 cells spawned from type2 cell
const nb_type2_spawn: int = 3;

# Stores the coods (Vec2) of every filled tile
var coords: Dictionary[Vector2i, Cell]
# List of the type (int) and center coords (Vec2) of cells
# order matters for rendering
var cells: Array[Cell] = [Cell.new(Vector2i(5, 5), Cell.CellType.TYPE1)];
# Coords of the tile under the mouse cursor
var mouse_tile: Vector2i;

func _ready() -> void:
	$Camera2D.position = tile_to_pos(CENTER);
	cells = [
		Cell.new(Vector2i(1_000, 1_000), Cell.CellType.TYPE1)
	];
	cells.shuffle()
	coords = Utils.cells_list_to_dict(cells)
	start_auto_move_to_center()
	
	var check_tile = Vector2i(1002, 1000);
	var new_cell = Cell.new(check_tile, Cell.CellType.TYPE2)
	coords[check_tile] = new_cell;
	for cell_child in new_cell.childs: coords[cell_child] = new_cell;
	var place_to_insert = 1;
	cells.insert(place_to_insert, new_cell);


func _process(_delta: float) -> void:
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
				merge()
			elif cell.cell_type == Cell.CellType.TYPE1:
				spawn_cell(mouse_tile, Cell.CellType.TYPE1)
			elif cell.cell_type == Cell.CellType.TYPE2:
				for _i in range(nb_type2_spawn):
					spawn_cell(mouse_tile, Cell.CellType.TYPE1)
			queue_redraw()
	if event is InputEventMouseMotion:
		var new_mouse_tile = pos_to_tile(get_global_mouse_position());
		if new_mouse_tile != mouse_tile:
			mouse_tile = new_mouse_tile;
			queue_redraw()


func _physics_process(_delta: float) -> void:
	set_can_merge(Cell.CellType.TYPE1)
	#set_can_merge(Cell.CellType.TYPE2)


func _draw() -> void:
	for i in range(10):
		for j in range(10):
			var pos = tile_to_pos(Vector2i(i, j))
			draw_circle(pos, h/2 * overh, Color.PALE_VIOLET_RED.lightened(0.6), false, 2)
	
	for cell in cells:
		var pos = tile_to_pos(cell.center)
		if cell.cell_type == Cell.CellType.TYPE1:
			var color = type1_color
			if cell.center == mouse_tile:
				color = color.lightened(0.2)
			if cell.can_merge:
				color = color.darkened(0.1)
			draw_circle(pos, h/2 * overh, color, true)
			draw_circle(pos, h/2 * overh, type1_color.darkened(0.2), false, 2)
		elif  cell.cell_type == Cell.CellType.TYPE2:
			var color = type2_color
			if cell.center == mouse_tile or mouse_tile in cell.childs:
				color = color.lightened(0.2)
			draw_circle(pos, h/2 * 3 * overh, color, true)
			draw_circle(pos, h/2 * 3 * overh, type2_color.darkened(0.2), false, 2)
	
	# draw_circle(tile_to_pos(mouse_tile), h/2 * overh, Color.INDIAN_RED, false, 3)

func merge() -> void:
	var mergeable_cells: Array[Cell] = cells.filter(func(cell): return cell.can_merge)

	for cell in mergeable_cells:
		if cell.cell_type == Cell.CellType.TYPE1:
			coords.erase(cell.center)
			cells.remove_at(cells.find(cell))
		elif cell.cell_type == Cell.CellType.TYPE2:
			pass
	
	for cell in mergeable_cells:
		if not check_if_coolide_with_type2(cell):
			var new_cell = Cell.new(cell.center, Cell.CellType.TYPE2)
			coords[cell.center] = new_cell;
			var place_to_insert = 1;
			if len(cells) > 1:
				place_to_insert = randi() % (len(cells) - 1) + 1;
			cells.insert(place_to_insert, new_cell);
			return

func check_if_coolide_with_type2(cell: Cell) -> bool:
	for i in range(6):
		if coords.has(Utils.moved_in_dir(cell.center, i)):
			return true
	return false


func spawn_cell(source_coords: Vector2i, cell_type: Cell.CellType):
	var spawn_dir = randi() % 6; # Choose 1 of 6 random directions (spawn_dir)
	var current_center = source_coords;
	while true:
		for i in range(6):
			var check_tile = Utils.moved_in_dir(current_center, (spawn_dir + i) % 6);
			if not coords.has(check_tile):
				var new_cell = Cell.new(check_tile, cell_type)
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
func move_cell(cell: Cell, new_position: Vector2i) -> void:
	coords.erase(cell.center)
	coords[new_position] = cell
	cell.center = new_position
	queue_redraw()

## Bouge une cellule vers le centre si possible
func try_to_move_to_center(cell: Cell) -> void:
	if cell.cell_type != Cell.CellType.TYPE1:
		return # TODO calcul different
	if cell.center == CENTER:
		return
	var direction = Utils.vec_to_direction(CENTER - cell.center)
	var new_position = Utils.moved_in_dir(cell.center, direction)
	if !coords.has(new_position):
		move_cell(cell, new_position)

## Set can_merge on all the cells of the first mergeable group
func set_can_merge(type: Cell.CellType):
	var cell_list: Array[Cell] = cells.duplicate(true)
	var first_cell_i = cell_list.find_custom(func(cell): return cell.cell_type == type)
	if first_cell_i == -1:
		return
	var first_cell: Cell = cell_list[first_cell_i]
	var merge_neighbourgs: Array[Cell] = []
	get_recursive_merge_neighbours(first_cell, cell_list, merge_neighbourgs)
	if len(merge_neighbourgs) + 1 < Cell.CELLS_N_FOR_TYPE2:
		return # not enought neighbourgs
	first_cell.can_merge = true
	for cell in merge_neighbourgs:
		cell.can_merge = true


func get_recursive_merge_neighbours(cell: Cell, cell_list: Array[Cell], merge_neighbourgs: Array[Cell], dbg_rec_level:= 0) :
	var new_positions = Utils.ALL_DIRECTION \
		.map(func(dir): return Utils.moved_in_dir(cell.center, dir)) \
		.filter(func(pos): return coords.has(pos) and cell_list.has(coords[pos]) and coords[pos].cell_type == cell.cell_type)

	var added_cells_to_check: Array[Cell] = []

	for pos in new_positions:
		cell_list.remove_at(cell_list.find(coords[pos]))
		merge_neighbourgs.push_back(coords[pos])
		added_cells_to_check.push_back(coords[pos])
		if len(merge_neighbourgs) + 1 >= Cell.CELLS_N_FOR_TYPE2:
			return

	for new_cell in added_cells_to_check:
		if len(merge_neighbourgs) + 1 >= Cell.CELLS_N_FOR_TYPE2:
			return
		get_recursive_merge_neighbours(
			new_cell,
			cell_list,
			merge_neighbourgs,
			dbg_rec_level + 1
		)
		if len(merge_neighbourgs) + 1 >= Cell.CELLS_N_FOR_TYPE2:
			return
