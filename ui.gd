extends CanvasLayer

@onready var total_cells: Label = $MarginContainer/VBoxContainer/TopPanel/TopBar/C1/TotalCells
@onready var current_goal: Label = $MarginContainer/VBoxContainer/TopPanel/TopBar/C2/CurrentGoal
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/TopPanel/TopBar/C2/ProgressBar
@onready var reset_button: TextureButton = $MarginContainer/VBoxContainer/TopPanel/TopBar/C3/Reset

@onready var left_grid: GridContainer = $MarginContainer/VBoxContainer/PanelContainer/PanelLeft/GridContainer
@onready var right_grid: GridContainer = $MarginContainer/VBoxContainer/PanelContainer/PanelRight/GridContainer

@onready var game: HexGrid = $"../Game"

var goal_step: int = 0
var last_cells_count: Array = []

const goals: Array[String] = [
	"Obtenir 12 cellules",
	"Former une Super cellule",
	"Obtenir 50 cellules",
	"Former 6 Super cellules",
	"Former une cellule usine",
	"Obtenir 500 cellules",
	"Former 12 cellules usines",
	"Former 1 cellules spéciale",
	"Obtenir 2000 cellules",
	"Obtenir 5000 cellules",
	"Obtenir 100'000 cellules",
]

const goals_max: Array[int] = [
	12, 1, 50, 6, 1, 500, 12, 1, 2000, 5000, 100_000,
]


func _ready():
	reset_button.pressed.connect(on_click_reset)


func _process(_delta: float):
	var cells_count: Array[int] = []
	for cells_of_kind in game.cells:
		cells_count.append(cells_of_kind.size())
	
	if cells_count != last_cells_count:
		last_cells_count = cells_count
		update_score()

func update_score():
	## Number of cells for each kind
	var cells_count: Array[int] = []
	for cells_of_kind in game.cells:
		cells_count.append(cells_of_kind.size())
	
	var nb_counted = int(left_grid.get_child_count()) / 2
	if nb_counted < Cell.NB_TYPES and cells_count[nb_counted] > 0:
		var new_label = left_grid.get_child(0).duplicate()
		new_label.text = Cell.NAMES[nb_counted] + " :"
		var new_label2 = left_grid.get_child(1).duplicate()
		new_label2.text = "1"
		left_grid.add_child(new_label)
		left_grid.add_child(new_label2)
	
	for i in nb_counted:
		left_grid.get_child(2 * i + 1).text = str(cells_count[i])
	
	var score = 0
	var value = 1
	for i in range(Cell.NB_TYPES):
		score += cells_count[i] * value
		value *= Cell.NB_CELL_FOR_MERGE[i] + 3
	total_cells.text = str(score)
	
	match goal_step:
		1, 3:
			progress_bar.update_value(cells_count[1])
		4, 6:
			progress_bar.update_value(cells_count[2])
		7:
			progress_bar.update_value(cells_count[3])
		_:
			progress_bar.update_value(score)

func on_click_reset():
	get_tree().reload_current_scene()

func next_step():
	goal_step += 1
	progress_bar.max_value = goals_max[goal_step]
	current_goal.text = goals[goal_step]
	update_score()
	$Win.play()
