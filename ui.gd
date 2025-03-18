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
	"Former 6 Super cellules",
	"Former une cellule usine",
	"Obtenir 500 cellules",
	"Former 15 cellules usines",
	"Former 1 cellules spéciale",
	"Obtenir 2000 cellules",
	"Obtenir 5000 cellules",
	"Obtenir 100'000 cellules",
]

const goals_max: Array[int] = [
	12, 1, 50, 6, 1, 500, 15, 1, 2000, 5000, 100_000,
]


func _ready() -> void:
	var reset_button: TextureButton = $PanelContainer/MarginContainer/TopBar/C3/Reset
	reset_button.pressed.connect(on_click_reset)


func update_score():
	var score = 0
	var nb_super_cells = 0
	var nb_factory_cells = 0
	var nb_special_cells = 0
	for cell in game.cells:
		match cell.kind:
			0:
				score += 1
			1:
				score += 13 #12
				nb_super_cells += 1
			2:
				score += 80 #13*6
				nb_factory_cells += 1
			3:
				score += 1250 #80*15
				nb_special_cells += 1
	
	total_cells.text = str(score)
	match goal_step:
		1, 3:
			progress_bar.update_value(nb_super_cells)
		4, 6:
			progress_bar.update_value(nb_factory_cells)
		7:
			progress_bar.update_value(nb_special_cells)
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
