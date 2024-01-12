class_name FloatingText
extends Node2D

# Credit to Ryan Mirch (Aecert Gaming)
# Link: https://www.youtube.com/watch?v=zGng3u9Y6dg

@onready var label:Label = $ContainerNode/Label
@onready var container_node:Node2D = $ContainerNode
@onready var animplayer:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_values_and_animate(value: String, start_pos:Vector2, height:float, spread:float, color: Color) -> void:
	label.text = value
	label.modulate = color
	label.scale = Vector2(0.5, 0.5)
	animplayer.play("Rise and Fade")
	
	var tween = get_tree().create_tween()
	var end_pos = Vector2(randf_range(-spread,spread),-height) + start_pos
	var tween_length = animplayer.get_animation("Rise and Fade").length
	tween.tween_property(container_node,"position",end_pos,tween_length).from(start_pos)
	
	
func remove() -> void:
	animplayer.stop()
	if is_inside_tree():
		get_parent().remove_child(self)


