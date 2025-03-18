extends CanvasLayer

@onready var total_cells: Label = $PanelContainer/MarginContainer/TopBar/C1/TotalCells
@onready var current_goal: Label = $PanelContainer/MarginContainer/TopBar/C2/CurrentGoal
@onready var progress_bar: ProgressBar = $PanelContainer/MarginContainer/TopBar/C2/ProgressBar
@onready var game: HexGrid = $"../Game"

var goal_step: int = 0

const goals: Array[String] = [
	"Obtenir 12 cellules",
	"Former une Super cellule",
	"Obtenir 50 cellules",
	"Former 8 Super cellules",
	"Former une cellule usine",
	"Obtenir 150 cellules",
	"Former 5 cellules usines",
	"Obtenir 500 cellules",
	"Obtenir 1000 cellules",
	"Obtenir 2000 cellules",
	"Obtenir 5000 cellules",
	"Obtenir 100'000 cellules",
]

const goals_max: Array[int] = [
	12, 1, 50, 8, 1, 150, 5, 500, 1000, 2000, 5000, 100_000,
]


func _ready() -> void:
	var reset_button: TextureButton = $PanelContainer/MarginContainer/TopBar/C3/Reset
	reset_button.pressed.connect(on_click_reset)


func update_score():
	var score = 0
	var nb_super_cells = 0
	var nb_factory_cells = 0
	for cell in game.cells:
		match cell.kind:
			0:
				score += 1
			1:
				score += 15
				nb_super_cells += 1
			2:
				score += 100
				nb_factory_cells += 1
	
	total_cells.text = str(score)
	match goal_step:
		0, 2, 5, 7, 8, 9, 10, 11:
			progress_bar.update_value(score)
		1, 3:
			progress_bar.update_value(nb_super_cells)
		4, 6:
			progress_bar.update_value(nb_factory_cells)


func on_click_reset():
	get_tree().reload_current_scene()

func next_step():
	goal_step += 1
	progress_bar.max_value = goals_max[goal_step]
	current_goal.text = goals[goal_step]
	update_score()
	$Win.play()
