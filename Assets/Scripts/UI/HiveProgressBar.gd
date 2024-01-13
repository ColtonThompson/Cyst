extends TextureProgressBar

@onready var hive = $"../../../Hive"
@onready var hive_health_label = $HiveHealthLabel

func update_bar():
	# Set the value of the bar to a percentage
	value = (hive.current_health * 100 / hive.max_health)

# Called when the node enters the scene tree for the first time.
func _ready():
	hive.health_changed.connect(self.update_bar)
	update_bar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_hive_health_changed():
	update_bar()
