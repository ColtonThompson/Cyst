extends Label

@onready var hive = $"../../../../Hive"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hp = hive.current_health
	var maxhp = hive.max_health
	if hp < 0:
		hp = 0
	text = str(hp) + "/" + str(maxhp)
