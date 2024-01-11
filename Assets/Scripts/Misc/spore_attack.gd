extends AnimatedSprite2D

func _ready():
	play("attack")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(), 1)
	tween.tween_property(self, "position", Vector2(), 1)
	tween.play()

func _on_timer_timeout():
	visible = false
	queue_free()
