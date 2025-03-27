extends CanvasLayer

@onready var total_cells: Label = $MarginContainer/VBoxContainer/TopPanel/TopBar/C1/TotalCells
@onready var current_goal: Label = $MarginContainer/VBoxContainer/TopPanel/TopBar/C2/CurrentGoal
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/TopPanel/TopBar/C2/ProgressBar
@onready var reset_button: TextureButton = $MarginContainer/VBoxContainer/TopPanel/TopBar/C3/Reset

@onready var panel_left: PanelContainer = $MarginContainer/VBoxContainer/PanelContainer/PanelLeft
@onready var panel_right: PanelContainer = $MarginContainer/VBoxContainer/PanelContainer/PanelRight
@onready var grid_left: GridContainer = $MarginContainer/VBoxContainer/PanelContainer/PanelLeft/GridContainer
@onready var grid_right: GridContainer = $MarginContainer/VBoxContainer/PanelContainer/PanelRight/GridContainer
@onready var upgrade_panel: PanelContainer = $MarginContainer/UpgradePanel
@onready var label_upgrade: Label = $MarginContainer/UpgradePanel/MarginContainer/LabelUpgrade
@onready var button_no: Button = $MarginContainer/UpgradePanel/MarginContainer/HBoxContainer/ButtonNo
@onready var button_yes: Button = $MarginContainer/UpgradePanel/MarginContainer/HBoxContainer/ButtonYes

@onready var game: HexGrid = $"../Game"

var last_cells_count: Array = []
var goal_step: int = 0
var power_step: int = 0

@onready var cell_assets = [
	load("res://assets/img/Cell-T0.svg"),
	load("res://assets/img/Cell-T1.svg"),
	load("res://assets/img/Cell-T2.svg"),
	load("res://assets/img/Cell-T3.svg"),
	load("res://assets/img/Cell-T4.svg"),
]

# Array of : (text, value to obtained, kind (-1 = tot))
var goals: Array = [
	["Obtenir " + str(Cell.NB_CELL_FOR_MERGE[0]) + " cellules", Cell.NB_CELL_FOR_MERGE[0], 0],
	["Former une Super cellule", 1, 1],
	["Obtenir 50 cellules", 50, -1],
	["Former " + str(Cell.NB_CELL_FOR_MERGE[1]) + " Super cellules", Cell.NB_CELL_FOR_MERGE[1], 1],
	["Former une cellule usine", 1, 2],
	["Obtenir 500 cellules", 500, -1],
	["Former " + str(Cell.NB_CELL_FOR_MERGE[2]) + " cellules usines", Cell.NB_CELL_FOR_MERGE[2], 2],
	["Former une cellules spéciale", 1, 3],
	["Obtenir 5000 cellules", 5000, -1],
	["Obtenir 100 Super cellules", 100, 1],
	["Former 5 cellules spéciales", Cell.NB_CELL_FOR_MERGE[3], 3],
	["Former une Super usine", 1, 4],
	["Obtenir 100'000 cellules", 100_000, -1],
	["Fin", 1000_000, -1],
	["Il n'y a plus rien ici", 100_000_000, 4],
]

var upgrades: Array = [
	"Doubler la prodution des usines ?",
	"Activer l'auto-merge ?",
	"Afficher le nombre de cellules de chaque type ?",
	"Doubler la vitesse de l’auto-merge ?",
	"Créer une super usine ?",
	"Encore doubler la prodution des usines ?",
	"Encore doubler la vitesse de l’auto-merge ?",
	"Activer l'auto-merge niveau 2 ?",
	"Afficher les statistiques de production ?",
	"Créer une super usine ?",
]


func _ready():
	reset_button.pressed.connect(on_click_reset)
	button_no.pressed.connect(on_button_no_pressed)
	button_yes.pressed.connect(on_button_yes_pressed)


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
	
	var nb_counted = int(grid_left.get_child_count()) / 2
	if nb_counted < Cell.NB_TYPES and cells_count[nb_counted] > 0:
		var new_texture_rect: TextureRect = grid_left.get_child(0).duplicate()
		new_texture_rect.texture = cell_assets[nb_counted]
		var new_label: Label = grid_left.get_child(1).duplicate()
		new_label.text = "1"
		grid_left.add_child(new_texture_rect)
		grid_left.add_child(new_label)
	
	for i in nb_counted:
		grid_left.get_child(2 * i + 1).text = Utils.humanize_number(cells_count[i])
	
	var score = 0
	var value = 1
	for i in range(Cell.NB_TYPES):
		score += cells_count[i] * value
		value *= Cell.NB_CELL_FOR_MERGE[i] + 3
	total_cells.text = Utils.humanize_number(score)
	
	var goal_kind = goals[goal_step][2]
	if goal_kind >= 0:
		progress_bar.update_value(cells_count[goal_kind])
	else:
		progress_bar.update_value(score)

func on_click_reset():
	get_tree().reload_current_scene()

func next_step():
	goal_step += 1
	progress_bar.max_value = goals[goal_step][1]
	current_goal.text = goals[goal_step][0]
	update_score()
	$Win.play()

func show_upgrade_pannel():
	label_upgrade.text = upgrades[power_step]
	upgrade_panel.show()
	

func on_button_no_pressed():
	game.freeze_mode = false
	upgrade_panel.hide()

func on_button_yes_pressed():
	var just_delete = true
	match power_step:
		0: game.FactoriesTimer.wait_time /= 2
		1: game.auto_merge_step = 1
		2: panel_left.show()
		3: game.AutoMergeTimer.wait_time /= 2
		4: just_delete = false
		5: game.FactoriesTimer.wait_time /= 2
		6: game.AutoMergeTimer.wait_time /= 2
		7: game.auto_merge_step = 2
		8: panel_right.show()
		9: just_delete = false
	
	power_step += 1
	game.merge(game.mergeable_cells, just_delete)
	game.freeze_mode = false
	upgrade_panel.hide()
