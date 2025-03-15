extends Node2D

const CENTER:= Vector2i(1_000, 1_000)
const hex_ratio: float = 2/sqrt(3);
const h: float = 50.0; # Cell size
const overh: float = 1;
const cam_smoothing: float = 0.002;

const type1_color: Color = Color.LIGHT_PINK;
const type2_color: Color = Color.LIGHT_SALMON;

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
		Cell.new(Vector2i(1_005, 1_005), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_006, 1_005), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_007, 1_005), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_008, 1_005), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_009, 1_005), Cell.CellType.TYPE1),
		#
		Cell.new(Vector2i(1_005, 1_006), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_006, 1_006), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_007, 1_006), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_008, 1_006), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_009, 1_006), Cell.CellType.TYPE1),
		#
		Cell.new(Vector2i(1_005, 1_007), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_006, 1_007), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_007, 1_007), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_008, 1_007), Cell.CellType.TYPE1),
		Cell.new(Vector2i(1_009, 1_007), Cell.CellType.TYPE1),
	];
	cells.shuffle()
	coords = Utils.cells_list_to_dict(cells)
	start_auto_move_to_center()


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
			spawn_cell(mouse_tile, Cell.CellType.TYPE1)
			queue_redraw()
	if event is InputEventMouseMotion:
		var new_mouse_tile = pos_to_tile(get_global_mouse_position());
		if new_mouse_tile != mouse_tile:
			mouse_tile = new_mouse_tile;
			queue_redraw()

func _draw() -> void:
	
	for i in range(10):
		for j in range(10):
			var pos = tile_to_pos(Vector2i(i, j))
			draw_circle(pos, h/2 * overh, Color.PALE_VIOLET_RED.lightened(0.6), false, 2)
	
	for cell in cells:
		var pos = tile_to_pos(cell.center)
		if cell.cell_type == Cell.CellType.TYPE1:
			if cell.center == mouse_tile:
				draw_circle(pos, h/2 * overh, type1_color.lightened(0.2), true)
			else:
				draw_circle(pos, h/2 * overh, type1_color, true)
			draw_circle(pos, h/2 * overh, type1_color.darkened(0.2), false, 2)
		elif  cell.cell_type == Cell.CellType.TYPE2:
			if cell.center == mouse_tile or mouse_tile in cell.childs:
				draw_circle(pos, h/2 * 2.5 * overh, type2_color.lightened(0.2), true)
			else:
				draw_circle(pos, h/2 * 2.5 * overh, type2_color, true)
			draw_circle(pos, h/2 * 2.5 * overh, type2_color.darkened(0.2), false, 2)
	
	# draw_circle(tile_to_pos(mouse_tile), h/2 * overh, Color.INDIAN_RED, false, 3)


func spawn_cell(source_coords: Vector2i, cell_type: Cell.CellType):
	var spawn_dir = randi() % 6; # Choose 1 of 6 random directions (spawn_dir)
	var current_center = source_coords;
	while true:
		for i in range(6):
			var check_tile = current_center + Utils.vec_from_dir((spawn_dir + i) % 6);
			if not coords.has(check_tile):
				var new_cell = Cell.new(check_tile, cell_type)
				coords[check_tile] = new_cell;
				var place_to_insert = randi() % len(cells);
				cells.insert(place_to_insert, new_cell);
				return
		current_center += Utils.vec_from_dir(spawn_dir);


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
	var new_position = cell.center + Utils.vec_from_dir(direction)
	if !coords.has(new_position):
		move_cell(cell, new_position)
