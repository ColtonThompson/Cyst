class_name ErrorMessage
extends Node2D

@onready var label:Label = $CanvasLayer/Control/Label
@onready var animplayer = $AnimationPlayer
@onready var container = $Container

func set_values_and_animate(value: String, color: Color) -> void:
	label.text = value
	label.modulate = color
	animplayer.play("display and fade")
	
func remove() -> void:
	animplayer.stop()
	if is_inside_tree():
		get_parent().remove_child(self)

