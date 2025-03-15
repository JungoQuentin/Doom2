extends Node2D

const hex_ratio: float = 2/sqrt(3);
const h: float = 40.0; # Cell size
const overh: float = 1;

# Stores the coods (Vec2) of every filled tile
var coords: Dictionary[Vector2i, CellType] = {Vector2i(5, 5): CellType.TYPE1};
# List of the type (int) and center coords (Vec2) of cells
# order matters for rendering
var cells: Array[Cell] = [Cell.new(Vector2i(5, 5), CellType.TYPE1)];
# Coords of the tile under the mouse cursor
var mouse_tile: Vector2i;


class Cell:
	var center: Vector2i;
	var cell_type: CellType;
	func _init(center: Vector2i, cell_type: CellType):
		self.center = center;
		self.cell_type = cell_type;


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		mouse_tile = pos_to_tile(event.position);
		if coords.has(mouse_tile):
			spawn_cell(mouse_tile, CellType.TYPE1)
			queue_redraw()
	if event is InputEventMouseMotion:
		var new_mouse_tile = pos_to_tile(event.position);
		if new_mouse_tile != mouse_tile:
			mouse_tile = new_mouse_tile;
			queue_redraw()

func _draw() -> void:
	"""
	for i in range(10):
		for j in range(10):
			var pos = tile2pos(Vector2i(i, j))
			draw_circle(pos, h/2 * overh, Color.PALE_VIOLET_RED.lightened(0.6), false, 2)
	"""
	for cell in cells:
		var pos = tile_to_pos(cell.center)
		if cell.center == mouse_tile:
			draw_circle(pos, h/2 * overh, Color.LIGHT_PINK.lightened(0.2), true)
		else:
			draw_circle(pos, h/2 * overh, Color.LIGHT_PINK, true)
		draw_circle(pos, h/2 * overh, Color.LIGHT_PINK.darkened(0.2), false, 2)


func spawn_cell(source_coords: Vector2i, cell_type: CellType):
	var dir_num = randi() % 6;
	print(dir_num)
	# Choose 1 of 6 random directions (spawn_dir)
	# Check is cell in 1 * spawn_dir is empty with hasmap "coords"
	# If not, check the 5 others cells
	# If still empty, check 2 * spawn_dir
	# ... reapete until find an empty cell
	# add coords of all taken cells in "coords"
	# add (center_coords, cell_type) at a random id in cells

	pass

func pos_to_tile(pos: Vector2) -> Vector2i:
	var odd = int(pos.y / h) % 2
	return Vector2i((pos.x / h / hex_ratio - 1 - 2/3.0 - odd/3.0), (pos.y / h) - 1.9)

func tile_to_pos(tile_coords: Vector2i) -> Vector2:
	var odd = tile_coords.y % 2;
	return h * Vector2(hex_ratio * tile_coords.x + odd * 0.5, tile_coords.y)
