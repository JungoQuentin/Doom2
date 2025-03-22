class_name HexGrid
extends Node2D

const CENTER:= Vector2i(1_000, 1_000)
const TIME_BETWEEN_MULTIPLE_SPAWN = 0.05
const hex_ratio: float = 2/sqrt(3)
const h: int = 64 # Cell size
const cam_smoothing: float = 0.002


## Stores the coods (Vec2i) of every filled tile
var coords: Dictionary[Vector2i, Cell]
## List of lists of cells by kind 
var cells: Array = []
## Coords of the tile under the mouse cursor
var mouse_tile: Vector2i
## List of mergeable cells
var mergeable_cells: Array[Cell] = []
## Step 1 means type0 cells will auto-merge
var auto_merge_step: int = 0

var t: float = 0.0
var auto_mergeable_cells: Array[Cell] = []
var multi_mesh_instances: Array[MultiMeshInstance2D] = []

@onready var Ui = $"../UI"
@onready var GravitateTimer: Timer = $GravitateTimer
@onready var FactoriesTimer: Timer = $FactoriesTimer
@onready var AutoMergeTimer: Timer = $AutoMergeTimer
@onready var AutoMergeHighlightTimer: Timer = $AutoMergeHighlightTimer


func _ready():
	for _i in range(Cell.NB_TYPES):
		cells.append([])
	cells[0].append(Cell.new(CENTER, 0))
	coords = Utils.cells_list_to_dict(cells)
	
	$Camera2D.position = tile_to_pos(CENTER)
	
	GravitateTimer.timeout.connect(move_cells_to_center)
	FactoriesTimer.timeout.connect(factory)
	AutoMergeTimer.timeout.connect(select_auto_merge)
	AutoMergeHighlightTimer.timeout.connect(auto_merge)
	
	# Create Multi-Mesh-Instance-2D for drawing
	for kind in range(Cell.NB_TYPES):
		var multi_mesh_instance = MultiMeshInstance2D.new()
		multi_mesh_instance.z_index = -1
		var multi_mesh = MultiMesh.new()
		var mesh = QuadMesh.new()
		mesh.size = h * Vector2.ONE * Cell.size[kind]
		multi_mesh.mesh = mesh
		multi_mesh.instance_count = 5000
		multi_mesh_instance.multimesh = multi_mesh
		# TODO utiliser différentes assets
		multi_mesh_instance.texture = load("res://assets/img/Cell-Type1.svg")
		
		multi_mesh_instances.append(multi_mesh_instance)
		$".".add_child(multi_mesh_instance)
	update_multi_mesh_instances()


func update_multi_mesh_instances():
	for kind in range(Cell.NB_TYPES):
		var nb_instances = cells[kind].size()
		multi_mesh_instances[kind].multimesh.visible_instance_count = nb_instances
		for i in nb_instances:
			var cell = cells[kind][i]
			var pos = tile_to_pos(cell.center)
			var mesh_transform = Transform2D(PI, Vector2.ONE, 0.0, pos)
			multi_mesh_instances[kind].multimesh.set_instance_transform_2d(i, mesh_transform)


func _process(delta: float):
	t += delta
	
	update_multi_mesh_instances()
	queue_redraw()
	
	# Camera zoom
	var window_size = get_viewport_rect().size
	var cells_y = coords.keys().map(func(pos): return pos.y)
	var v_max = max(cells_y.max() - CENTER.y, CENTER.y - cells_y.min()) + 1
	var cells_x = coords.keys().map(func(pos): return pos.y)
	var h_max = max(cells_x.max() - CENTER.x, CENTER.x - cells_x.min()) + 1
	var zoom = max(1, 2 * h * max(v_max / window_size.y, h_max / window_size.x))
	$Camera2D.zoom = $Camera2D.zoom * (1 - cam_smoothing) + Vector2.ONE / zoom * cam_smoothing


func _draw():
	if not mergeable_cells.is_empty():
		for cell in mergeable_cells:
			draw_circle(tile_to_pos(cell.center), h / 2 * Cell.size[cell.kind], Color.LIGHT_PINK.darkened(0.1))
	elif coords.has(mouse_tile):
		var cell = coords[mouse_tile]
		draw_circle(tile_to_pos(cell.center), h / 2 * Cell.size[cell.kind], Color.LIGHT_PINK.darkened(0.1))
	
	if !auto_mergeable_cells.is_empty():
		for cell in auto_mergeable_cells:
			draw_circle(tile_to_pos(cell.center), h / 2 * Cell.size[cell.kind], Color.LIGHT_PINK.lightened(0.2))


func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		if event.pressed:
			mouse_tile = pos_to_tile(get_global_mouse_position())
			if coords.has(mouse_tile):
				var cell = coords[mouse_tile]
				if cell in mergeable_cells:
					if cell.kind == 2 and auto_merge_step == 0:
						auto_merge_step = 1;
					merge(mergeable_cells, cell.kind)
				else:
					spawn_many(Cell.NB_SPAWN_CELL[cell.kind])
		else:
			mergeable_cells = Merge.get_mergeable_cells(coords, mouse_tile)
		
	if event is InputEventMouseMotion:
		var new_mouse_tile = pos_to_tile(get_global_mouse_position())
		if new_mouse_tile != mouse_tile:
			mouse_tile = new_mouse_tile
			mergeable_cells = Merge.get_mergeable_cells(coords, mouse_tile)


func spawn_many(q: int):
	for _i in range(q):
		await get_tree().create_timer(TIME_BETWEEN_MULTIPLE_SPAWN).timeout
		spawn_cell(mouse_tile, 0)
		$PopT1.play()


func factory():
	for cell in cells.duplicate()[2]:
		await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
		spawn_cell(cell.center, 0)
		$PopT1.play()


func select_auto_merge():
	if auto_merge_step < 1:
		return
	var filtered_cells: Array = cells[0]
	if filtered_cells.is_empty():
		return
	auto_mergeable_cells.clear()
	for _i in range(5):
		if auto_mergeable_cells.is_empty():
			var start_cell = filtered_cells[randi() % filtered_cells.size()]
			auto_mergeable_cells = Merge.get_mergeable_cells(coords, start_cell.center)
	if auto_mergeable_cells.is_empty():
		return
	AutoMergeHighlightTimer.start()


func auto_merge():
	if auto_mergeable_cells.is_empty():
		return
	merge(auto_mergeable_cells, 0)
	auto_mergeable_cells.clear()


func merge(cells_to_merge: Array[Cell], kind: int):
	match kind:
		0, 1, 2, 3:
			$PopT2.play()
	
	for cell in cells_to_merge:
		delete_cell(cell)
	
	for cell in cells_to_merge:
		if not Utils.are_there_bigger_or_same_cells_around(cell.center, coords, cell.kind + 1, cell):
			var new_cell = Cell.new(cell.center, cell.kind + 1)
			for child in new_cell.childs:
				if coords.has(child) and coords[child].kind == 0:
					delete_cell(coords[child])
			coords[cell.center] = new_cell
			for cell_child in new_cell.childs:
				coords[cell_child] = new_cell
			add_cell(new_cell)
			return
	print("FAILED Merge")


func spawn_cell(source_coords: Vector2i, kind: int, _dir: int = -1):
	var spawn_dir = _dir
	if _dir == -1:
		spawn_dir = randi() % 6 # Choose 1 of 6 random directions (spawn_dir)
	var current_center = source_coords
	while true:
		var dir = randi_range(5, 7)
		var pos = Utils.moved_in_dir(current_center, (spawn_dir + dir) % 6)
		if not Utils.are_there_cells_around(pos, coords, kind):
			var new_cell = Cell.new(pos, kind)
			for child in new_cell.childs:
				coords[child] = new_cell
			add_cell(new_cell)
			return
		current_center = Utils.moved_in_dir(current_center, (spawn_dir + dir) % 6)

func pos_to_tile(pos: Vector2) -> Vector2i:
	var odd = int(pos.y / h - 0.5) % 2
	return Vector2i(int(pos.x / h / hex_ratio + 0.08 + odd*0.37), int((pos.y / h) + 0.5))

func tile_to_pos(tile_coords: Vector2i) -> Vector2:
	var odd = tile_coords.y % 2
	return h * Vector2(hex_ratio * tile_coords.x + odd * 0.5, tile_coords.y)

## Bouge une cellule vers le centre si possible
func move_cells_to_center():
	if coords.size() < 6:
		return
	for kind in range(Cell.NB_TYPES): # range(Cell.NB_TYPES - 1, -1, -1):
		for cell in cells[kind]:
			if cell.center == CENTER:
				continue
			var direction = Utils.angle_to_direction(rad_to_deg(Vector2(CENTER - cell.center).angle()) + (randf() - 0.5) * 90)
			var new_position = Utils.moved_in_dir(cell.center, direction)
			if not Utils.are_there_bigger_or_same_cells_around(new_position, coords, kind, cell):
				move_cell(cell, direction)

## Déplace une cellule dans une direction
func move_cell(cell: Cell, dir: Utils.Direction):
	var victims = []
	for child in cell.childs:
		coords.erase(child)
		var moved_child_pos = Utils.moved_in_dir(child, dir)
		if coords.has(moved_child_pos):
			var moved_child = coords[moved_child_pos]
			if moved_child.kind < cell.kind:
				victims.append(moved_child.kind)
				delete_cell(moved_child)
	for child_i in cell.childs.size():
		var moved_child_pos = Utils.moved_in_dir(cell.childs[child_i], dir)
		cell.childs[child_i] = moved_child_pos
		coords[moved_child_pos] = cell
	cell.center = Utils.moved_in_dir(cell.center, dir)
	for victim in victims:
		spawn_cell(cell.center, victim, (dir + 3) % 6)


## Add a new cell
func add_cell(cell: Cell):
	cells[cell.kind].append(cell)
	

## Delete the cell and corresponding coords
func delete_cell(cell: Cell):
	var cells_of_kind = cells[cell.kind]
	if cells_of_kind.has(cell):
		cells_of_kind.remove_at(cells_of_kind.find(cell))
	for child in cell.childs:
		coords.erase(child)
