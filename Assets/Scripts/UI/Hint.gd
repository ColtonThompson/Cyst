extends Label

var tick = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	if tick == 0:
		modulate.a = lerp(modulate.a, 0.0, 0.01)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tick > 0:
		tick -= 1
	queue_redraw()
