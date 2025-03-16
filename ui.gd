extends CanvasLayer

@onready var total_cells: Label = $TopBar/C1/TotalCells
@onready var game: Doom2 = $"../Game"

func _ready() -> void:
	var reset_button: TextureButton = $TopBar/C3/Reset
	reset_button.pressed.connect(on_click_reset)


func _process(_delta: float) -> void:
	var tot = 0
	for cell in game.cells:
		if cell.cell_type == Cell.CellType.TYPE1:
			tot += 1
		elif cell.cell_type == Cell.CellType.TYPE2:
			tot += 15
		elif cell.cell_type == Cell.CellType.TYPE3:
			tot += 100
	total_cells.text = str(tot)


func on_click_reset() -> void:
	get_tree().reload_current_scene()
