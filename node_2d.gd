extends Node2D

enum CellType{ TYPE1, TYPE2 }

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print("left click", mouse_tile)
	if event is InputEventMouseMotion:
		mouse_tile = pos2tile(event.position);
		print("move", event.position)

func _draw() -> void:
	for cell in cells:
		var pos = tile2pos(cell.center)
		draw_circle(pos, h/2 * overh, Color.LIGHT_PINK, true)
		draw_circle(pos, h/2 * overh, Color.LIGHT_PINK.darkened(0.2), false, 2)


func spawn_cell(source_pos, cell_type):
	# Choose 1 of 6 random directions (spawn_dir)
	# Check is cell in 1 * spawn_dir is empty with hasmap "coords"
	# If not, check the 5 others cells
	# If still empty, check 2 * spawn_dir
	# ... reapete until find an empty cell
	# add coords of all taken cells in "coords"
	# add (center_coords, cell_type) at a random id in cells
	pass

func pos2tile(pos: Vector2) -> Vector2i:
	return Vector2i(0, 0)

func tile2pos(tile_coords: Vector2i) -> Vector2:
	var odd = tile_coords.y % 2;
	return h * Vector2(hex_ratio * tile_coords.x + odd * 0.5, tile_coords.y)
	
