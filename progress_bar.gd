extends ProgressBar

@onready var timer: Timer = $Timer
@onready var Ui = $"../../../../../.."
var old_value: float = 1
var new_value: float = 1


func _ready():
	timer.timeout.connect(timeout)


func _process(_delta: float):
	if timer.is_stopped():
		return
	var t = 1 - timer.time_left / timer.wait_time
	value = lerp(old_value, new_value, t)


func update_value(updated_value: int):
	old_value = new_value
	new_value = updated_value
	timer.start()
	

func timeout():
	value = new_value
	if value == max_value:
		Ui.next_step()
