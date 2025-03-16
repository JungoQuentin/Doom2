extends CanvasLayer

@onready var total_cells: Label = $TopBar/C1/TotalCells
@onready var game: Doom2 = $"../Game"

func _ready() -> void:
	var reset_button: TextureButton = $TopBar/C3/Reset
	reset_button.pressed.connect(on_click_reset)


func _process(_delta: float) -> void:
	total_cells.text = str(game.coords.size())


func on_click_reset() -> void:
	get_tree().reload_current_scene()
