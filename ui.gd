extends CanvasLayer

func _ready() -> void:
	var reset_button: TextureButton = $TopBar/C3/Reset
	reset_button.pressed.connect(on_click_reset)

func on_click_reset() -> void:
	get_tree().reload_current_scene()
