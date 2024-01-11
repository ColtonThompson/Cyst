extends Node2D

var radius = 1
var max_radius = GameManager.infestation_radius
var color_infestation: Color = Color.INDIAN_RED

func grow():
	if radius < max_radius:
		radius += 1
			
func _draw():
	draw_circle(Vector2i(0,0), radius, color_infestation)

func _on_growth_timer_timeout():
	grow()
	queue_redraw()
