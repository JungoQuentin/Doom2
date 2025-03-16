extends CanvasLayer

@onready var total_cells: Label = $TopBar/C1/TotalCells
@onready var current_goal: Label = $TopBar/C2/CurrentGoal
@onready var progress_bar: ProgressBar = $TopBar/C2/ProgressBar
@onready var game: Doom2 = $"../Game"

var goal_step: int = 0;

const goals: Array[String] = [
	"Dupliquez une cellule !",
	"Obtenir 12 cellules",
	"Former une Super cellule",
	"Obtenir 50 cellules",
	"Former 5 Super cellules",
	"Former une cellule usine",
	"Obtenir 150 cellules",
	"Former 5 cellules usines",
	"Obtenir 500 cellules",
	"Obtenir 1000 cellules",
	"Obtenir 2000 cellules",
]


func _ready() -> void:
	var reset_button: TextureButton = $TopBar/C3/Reset
	reset_button.pressed.connect(on_click_reset)


func _process(_delta: float) -> void:
	var tot = 0
	var nb_super_cells = 0
	var nb_factory_cells = 0
	for cell in game.cells:
		if cell.cell_type == Cell.CellType.TYPE1:
			tot += 1
		elif cell.cell_type == Cell.CellType.TYPE2:
			tot += 15
			nb_super_cells += 1
		elif cell.cell_type == Cell.CellType.TYPE3:
			tot += 100
			nb_factory_cells += 1
	total_cells.text = str(tot)
	
	if goal_step == 0:
		progress_bar.max_value = 1
		progress_bar.value = 0
		if tot >= 2:
			progress_bar.value = 1
			goal_step += 1
	elif goal_step == 1:
		progress_bar.max_value = 12
		progress_bar.value = tot
		if tot >= 12:
			goal_step += 1
	elif goal_step == 2:
		progress_bar.value = tot
		if nb_super_cells >= 1:
			goal_step += 1
	elif goal_step == 3:
		progress_bar.max_value = 50
		progress_bar.value = tot
		if tot >= 50:
			goal_step += 1
	elif goal_step == 4:
		progress_bar.max_value = 5
		progress_bar.value = nb_super_cells
		if nb_super_cells >= 5:
			goal_step += 1
	elif goal_step == 5:
		if nb_factory_cells >= 1:
			goal_step += 1
	elif goal_step == 6:
		progress_bar.max_value = 150
		progress_bar.value = tot
		if tot >= 150:
			goal_step += 1
	elif goal_step == 7:
		progress_bar.max_value = 5
		progress_bar.value = nb_factory_cells
		if nb_factory_cells >= 5:
			goal_step += 1
	elif goal_step == 8:
		progress_bar.max_value = 500
		progress_bar.value = tot
		if tot >= 500:
			goal_step += 1
	elif goal_step == 9:
		progress_bar.max_value = 1000
		progress_bar.value = tot
		if tot >= 1000:
			goal_step += 1
	elif goal_step == 10:
		progress_bar.max_value = 2000
		progress_bar.value = tot
		if tot >= 2000:
			goal_step += 1
	
	current_goal.text = goals[goal_step]


func on_click_reset() -> void:
	get_tree().reload_current_scene()
