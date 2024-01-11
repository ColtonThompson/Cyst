extends Label

var tick = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tick > 0:
		tick -= 1
	if tick > 0:
		modulate.a -= 0.3 * delta
		if modulate.a < 0:
			modulate.a = 0
	if tick == 0:
		visible = false
	
func _on_game_world_info_signal():
	visible = true
	tick = 500
