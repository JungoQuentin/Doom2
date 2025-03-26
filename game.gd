class_name HexGrid
extends Node2D

const CENTER:= Vector2i(1_000, 1_000)
const TIME_BETWEEN_MULTIPLE_SPAWN = 0.05
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

var is_touch_screen: bool = false

var t: float = 0.0
var auto_mergeable_cells: Array[Cell] = []
var multi_mesh_instances: Array[MultiMeshInstance2D] = []

@onready var Ui = $"../UI"
@onready var GravitateTimer: Timer = $GravitateTimer
@onready var FactoriesTimer: Timer = $FactoriesTimer
@onready var AutoMergeTimer: Timer = $AutoMergeTimer
@onready var AutoMergeHighlightTimer: Timer = $AutoMergeHighlightTimer
@onready var cell_assets = [
	load("res://assets/img/Cell-T0.svg"),
	load("res://assets/img/Cell-T1.svg"),
	load("res://assets/img/Cell-T2.svg"),
	load("res://assets/img/Cell-T3.svg"),
	load("res://assets/img/Cell-T4.svg"),
]


func _ready():
	for _i in range(Cell.NB_TYPES):
		cells.append([])
	cells[0].append(Cell.new(CENTER, 0))
	coords = Utils.cells_list_to_dict(cells)
	
	$Camera2D.position = Utils.tile_to_pos(CENTER)
	
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
		mesh.size = Utils.h * Vector2.ONE * Cell.SIZE[kind]
		multi_mesh.mesh = mesh
		multi_mesh.instance_count = Cell.INSTANCE_COUNT[kind]
		multi_mesh_instance.multimesh = multi_mesh
		multi_mesh_instance.texture = cell_assets[kind]
		multi_mesh_instances.append(multi_mesh_instance)
		$".".add_child(multi_mesh_instance)
	update_multi_mesh_instances()


func update_multi_mesh_instances():
	for kind in range(Cell.NB_TYPES):
		var nb_instances = cells[kind].size()
		multi_mesh_instances[kind].multimesh.visible_instance_count = nb_instances
		for i in nb_instances:
			var cell = cells[kind][i]
			var pos = Utils.tile_to_pos(cell.center)
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
	var zoom = max(1, 2 * Utils.h * max(v_max / window_size.y, h_max / window_size.x))
	$Camera2D.zoom = $Camera2D.zoom * (1 - cam_smoothing) + Vector2.ONE / zoom * cam_smoothing


func _draw():
	var hover_color = Color.BLACK
	hover_color.a = 0.15
	if not mergeable_cells.is_empty():
		for cell in mergeable_cells:
			draw_circle(Utils.tile_to_pos(cell.center), Utils.h / 2 * Cell.SIZE[cell.kind], hover_color)
	elif coords.has(mouse_tile):
		var cell = coords[mouse_tile]
		draw_circle(Utils.tile_to_pos(cell.center), Utils.h / 2 * Cell.SIZE[cell.kind], hover_color)
	
	if !auto_mergeable_cells.is_empty():
		for cell in auto_mergeable_cells:
			draw_circle(Utils.tile_to_pos(cell.center), Utils.h / 2 * Cell.SIZE[cell.kind], Color.LIGHT_PINK.lightened(0.2))


func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		is_touch_screen = true
		if event.pressed:
			mouse_tile = Utils.pos_to_tile(get_global_mouse_position())
			if coords.has(mouse_tile):
				var cell = coords[mouse_tile]
				if cell in mergeable_cells:
					if cell.kind == 2 and auto_merge_step == 0:
						auto_merge_step = 1;
					merge(mergeable_cells)
				else:
					spawn_many(Cell.NB_SPAWN_CELL[cell.kind])
		else:
			var new_mouse_tile = Utils.pos_to_tile(get_global_mouse_position())
			if new_mouse_tile != mouse_tile:
				mouse_tile = new_mouse_tile
				mergeable_cells = Merge.get_mergeable_cells(coords, mouse_tile)
			mergeable_cells = Merge.get_mergeable_cells(coords, mouse_tile)
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		if event.pressed:
			mouse_tile = Utils.pos_to_tile(get_global_mouse_position())
			if coords.has(mouse_tile):
				var cell = coords[mouse_tile]
				if cell in mergeable_cells:
					if cell.kind == 2 and auto_merge_step == 0:
						auto_merge_step = 1;
					merge(mergeable_cells)
				else:
					spawn_many(Cell.NB_SPAWN_CELL[cell.kind])
		else:
			mergeable_cells = Merge.get_mergeable_cells(coords, mouse_tile)
		
	if event is InputEventMouseMotion:
		var new_mouse_tile = Utils.pos_to_tile(get_global_mouse_position())
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
	for cell in cells.duplicate()[4]:
		await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
		spawn_cell(cell.center, 2)
		await get_tree().create_timer(randf_range(0.05, 0.15)).timeout
		spawn_cell(cell.center, 2)
		$PopT1.play()


func select_auto_merge():
	if auto_merge_step < 1:
		return
	var filtered_cells: Array = cells[0]
	if filtered_cells.is_empty():
		return
	auto_mergeable_cells.clear()
	for _i in range(15):
		if auto_mergeable_cells.is_empty():
			var start_cell = filtered_cells[randi() % filtered_cells.size()]
			auto_mergeable_cells = Merge.get_mergeable_cells(coords, start_cell.center)
	if auto_mergeable_cells.is_empty():
		return
	AutoMergeHighlightTimer.start()


func auto_merge():
	if auto_mergeable_cells.is_empty():
		return
	merge(auto_mergeable_cells)
	auto_mergeable_cells.clear()


func merge(cells_to_merge: Array[Cell]):
	var kind = cells_to_merge[0].kind
	match kind:
		0, 1, 2, 3:
			$PopT2.play()
	
	for cell in cells_to_merge:
		delete_cell(cell)
	
	var centers = cells_to_merge.map(func(cell): return cell.center)
	var center = centers.reduce(func(a, b): return a + b, Vector2i.ZERO) / cells_to_merge.size()
	spawn_cell(center, kind + 1)


func spawn_cell(source_coords: Vector2i, kind: int):
	var dist_to_center = Vector2(source_coords - CENTER)
	var spawn_dir
	var current_center = source_coords
	while true:
		if dist_to_center.length_squared() < 10:
			spawn_dir = randi() % 6 # Choose 1 of 6 random directions (spawn_dir)
		else:
			spawn_dir = Utils.angle_to_direction(rad_to_deg(dist_to_center.angle()) + (randf() - 0.5) * 100)
		var dir = randi_range(5, 7)
		var pos = Utils.moved_in_dir(current_center, (spawn_dir + dir) % 6)
		if not Utils.are_there_bigger_or_same_cells_around(pos, coords, kind, null):
			var new_cell = Cell.new(pos, kind)
			
			var victims = []
			for child in new_cell.childs:
				if coords.has(child):
					var child_cell = coords[child]
					if child_cell.kind < kind:
						victims.append(child_cell.kind)
						delete_cell(child_cell)
				coords[child] = new_cell
			cells[kind].append(new_cell)
			for victim in victims:
				spawn_cell(new_cell.center, victim)
			return
		current_center = Utils.moved_in_dir(current_center, (spawn_dir + dir) % 6)


## Bouge une cellule vers le centre si possible
func move_cells_to_center():
	if coords.size() < 6:
		return
	for kind in range(Cell.NB_TYPES): # range(Cell.NB_TYPES - 1, -1, -1):
		for cell in cells[kind]:
			for _i in range(3):
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
		spawn_cell(cell.center, victim)

## Delete the cell and corresponding coords
func delete_cell(cell: Cell):
	var cells_of_kind = cells[cell.kind]
	if cells_of_kind.has(cell):
		cells_of_kind.remove_at(cells_of_kind.find(cell))
	for child in cell.childs:
		coords.erase(child)
