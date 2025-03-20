extends MultiMeshInstance2D

var t: float = 0
var rnd = []
var rnd2 = []


func _ready():
	for i in multimesh.instance_count:
		rnd.append(randf())
		rnd2.append(randf())
		var angle = PI
		var pos = 300 * Vector2.ONE + 80 * Vector2(i, i % 2)
		var transform = Transform2D(angle, Vector2(1, 1), 0.0, pos)
		multimesh.set_instance_transform_2d(i, transform)


func _process(delta: float):
	t += delta
	
	for i in multimesh.instance_count:
		var angle = PI + t * 3.5 * (rnd[i] - 0.5)
		var pos = 300 * Vector2.ONE + 80 * Vector2(i, i % 2) + 10 * Vector2.from_angle(t * 5.0 * (rnd2[i] - 0.5))
		var skew = 0.07 * (rnd[i] + 1.5) * (8 + cos(t * (rnd2[i] + 1.5)))
		var transform = Transform2D(angle, Vector2(1 / skew, skew), 0.0, pos)
		multimesh.set_instance_transform_2d(i, transform)
