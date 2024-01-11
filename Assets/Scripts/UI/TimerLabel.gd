extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.game_over:
		return
	GameManager.time_elapsed += delta
	text = str(format_time(GameManager.time_elapsed))
	
func format_time(time: float):
	var minutes := time / 60
	var seconds := fmod(time, 60)
	var time_string := "%02d:%02d" % [minutes, seconds]
	return time_string
