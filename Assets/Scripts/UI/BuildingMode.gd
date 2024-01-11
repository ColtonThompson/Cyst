extends Label

func _process(delta):
	text = "Building Mode: " + str(GameManager.building_mode)
