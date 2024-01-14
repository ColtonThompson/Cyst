extends AnimatedSprite2D

func _ready():
	play_animation()

func play_animation():
	play("attack")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(), 1)
	tween.tween_property(self, "position", Vector2(), 1)
	tween.play()

func reload_and_play(pos: Vector2):
	set_position(pos)
	play_animation()
	
func _on_timer_timeout():
	visible = false
