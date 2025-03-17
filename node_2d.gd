class_name Doom2
extends Node2D

const CENTER:= Vector2i(1_000, 1_000)
const TIME_BETWEEN_MULTIPLE_SPAWN = 0.05
const hex_ratio: float = 2/sqrt(3);
const h: float = 50.0; # Cell size
const cam_smoothing: float = 0.005;


## Stores the coods (Vec2i) of every filled tile
var coords: Dictionary[Vector2i, Cell]
## List of the Cells (order matters for rendering)
var cells: Array[Cell] = [Cell.new(CENTER, 0)];
## Coords of the tile under the mouse cursor
var mouse_tile: Vector2i;
## List of mergeable cells
var mergeable_cells: Array[Cell] = []

var b: float = 0.0;

func _ready() -> void:
	$Camera2D.position = tile_to_pos(CENTER);
	coords = Utils.cells_list_to_dict(cells)
	start_auto_move_to_center()
	start_factories()


func _process(delta: float) -> void:
	b += delta * 4;
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_tile = pos_to_tile(get_global_mouse_position());
			if coords.has(mouse_tile):
				var cell = coords[mouse_tile];
				if cell in mergeable_cells:
					merge(cell.kind)
				else:
					spawn_many(Cell.NB_SPAWN_CELL[cell.kind])
		else:
			Merge.set_can_merge(cells, coords, mouse_tile, mergeable_cells)
	if event is InputEventMouseMotion:
		var new_mouse_tile = pos_to_tile(get_global_mouse_position());
		if new_mouse_tile != mouse_tile:
			mouse_tile = new_mouse_tile;
			Merge.set_can_merge(cells, coords, mouse_tile, mergeable_cells)


func spawn_many(q: int) -> void:
	for _i in range(q):
		await get_tree().create_timer(TIME_BETWEEN_MULTIPLE_SPAWN).timeout
		spawn_cell(mouse_tile, 0)
		$PopT1.play()


func _draw() -> void:
	"""
	for i in range(980, 1020):
		for j in range(980, 1020):
			var pos = tile_to_pos(Vector2i(i, j))
			draw_circle(pos, h/2, Color.PALE_VIOLET_RED.lightened(0.6), false, 2)
	"""
	for cell in cells:
		var pos = tile_to_pos(cell.center);
		var size = Cell.size[cell.kind];
		var color = Cell.color[cell.kind];
		var fill_color = color;
		if cell in mergeable_cells or mouse_tile in cell.childs:
			fill_color = color.darkened(0.1);
		
		var offset = 3 * cell.rnd[0] * Vector2(cos((cell.rnd[1] - 0.5) * b), sin((cell.rnd[1] - 0.5) * b))
		var offset_center = offset + 4 * cell.rnd[2] * Vector2(-cos((cell.rnd[3] - 0.5) * b / 2), sin((cell.rnd[3] - 0.5) * b / 2))
		
		draw_circle(pos + offset * size, h/2 * size, fill_color, true)
		draw_circle(pos + offset * size, h/2 * size, color.darkened(0.1), false, 3)
		draw_circle(pos + offset_center * size, h/8 * size, color.darkened(0.15), true)
	"""
	for coord in coords: # DEBUG
		var kind = coords[coord].kind
		var col
		if kind == 1:
			col = Color.BEIGE
		elif kind == 2:
			col = Color.SADDLE_BROWN
		else:
			col = Color.DODGER_BLUE
		draw_circle(tile_to_pos(coord), h/8, col, true)
	"""
	# draw_circle(tile_to_pos(mouse_tile), h/2 * overh, Color.INDIAN_RED, false, 3)


func start_factories() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.8 # une cellule type1 toutes les 2 secondes
	timer.timeout.connect(factory)
	timer.autostart = true
	timer.start()


func factory():
	for cell in cells.duplicate():
		if cell.kind == 3:
			await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
			spawn_cell(cell.center, 0)
			$PopT1.play()


func merge(kind: int) -> void:
	for cell in mergeable_cells:
		match kind:
			0:
				coords.erase(cell.center)
				cells.remove_at(cells.find(cell))
				$PopT2.play()
			1:
				for child in cell.childs:
					coords.erase(child)
				coords.erase(cell.center)
				cells.remove_at(cells.find(cell))
				$PopT2.play()
			2:
				for child in cell.childs:
					coords.erase(child)
				coords.erase(cell.center)
				cells.remove_at(cells.find(cell))
				$PopT2.play()
	
	for cell in mergeable_cells:
		if not Utils.are_there_bigger_or_same_cells_around(cell.center, coords, cell.kind + 1, cell):
			var new_cell = Cell.new(cell.center, cell.kind + 1)
			for child in new_cell.childs:
				if coords.has(child) and coords[child].kind == 0:
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


func spawn_cell(source_coords: Vector2i, kind: int):
	var spawn_dir = randi() % 6; # Choose 1 of 6 random directions (spawn_dir)
	var current_center = source_coords;
	while true:
		var dir = randi_range(5, 7);
		var position = Utils.moved_in_dir(current_center, (spawn_dir + dir) % 6);
		if not Utils.are_there_cells_around(position, coords, kind):
			var new_cell = Cell.new(position, 0)
			for child in new_cell.childs:
				coords[child] = new_cell;
			var place_to_insert = 1;
			if len(cells) > 1:
				place_to_insert = randi() % (len(cells) - 1) + 1;
			cells.insert(place_to_insert, new_cell);
			return
		current_center = Utils.moved_in_dir(current_center, (spawn_dir + dir) % 6);

func pos_to_tile(pos: Vector2) -> Vector2i:
	var odd = int(pos.y / h - 0.5) % 2
	return Vector2i((pos.x / h / hex_ratio + 0.08 + odd*0.37), (pos.y / h) + 0.5)

func tile_to_pos(tile_coords: Vector2i) -> Vector2:
	var odd = tile_coords.y % 2;
	return h * Vector2(hex_ratio * tile_coords.x + odd * 0.5, tile_coords.y)


## Lance la logique de deplacement automatique vers le centre
## Un timer qui run toutes les x secondes
func start_auto_move_to_center():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.05
	timer.timeout.connect(func(): cells.map(func(cell): try_to_move_to_center(cell)))
	timer.autostart = true
	timer.start()

## Bouge une cellule vers le centre si possible
func try_to_move_to_center(cell: Cell):
	if cell.center == CENTER or len(cells) <= 7:
		return
	var angle = rad_to_deg(Vector2(CENTER - cell.center).angle());
	angle += (randf() - 0.5) * 90;
	var direction = Utils.angle_to_direction(angle);
	var new_position = Utils.moved_in_dir(cell.center, direction)
	
	if not Utils.are_there_bigger_or_same_cells_around(new_position, coords, cell.kind, cell):
		move_cell(cell, direction)

## Déplace une cellule dans une direction
func move_cell(cell: Cell, dir: Utils.Direction):
	var victims = [];
	for child_index in cell.childs.size():
		var moved_child = Utils.moved_in_dir(cell.childs[child_index], dir);
		if coords.has(moved_child) and coords[moved_child].kind < cell.kind:
			victims.append(coords[moved_child].kind)
			delete_cell(moved_child);
		cell.childs[child_index] = Utils.moved_in_dir(cell.childs[child_index], dir);
	for victim in victims:
		spawn_cell(cell.center, victim)
	cell.center = Utils.moved_in_dir(cell.center, dir)

## Delete the cell and corresponding coords at a given position
func delete_cell(position: Vector2i):
	if not coords.has(position):
		return
	var cell = coords[position];
	for child in cell.childs:
		coords.erase(child);
	cells.remove_at(cells.find(cell));
