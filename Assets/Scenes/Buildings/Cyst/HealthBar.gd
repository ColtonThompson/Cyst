extends TextureProgressBar

@onready var cyst = $".."

var wait_before_fade = 1000

func update_bar():
	# Set the value of the bar to a percentage
	value = (cyst.current_health * 100 / cyst.max_health)

# Called when the node enters the scene tree for the first time.
func _ready():
	cyst.health_changed.connect(self.update_bar)
	update_bar()

func _draw():
	if wait_before_fade == 0:
		modulate.a = lerp(modulate.a, 0.0, 0.01)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wait_before_fade > 0:
		wait_before_fade -= 1
	queue_redraw()
	

func _on_cyst_health_changed():
	wait_before_fade = 1000
	modulate.a = 1
	update_bar()
