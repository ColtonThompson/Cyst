extends Node2D

@onready var infestation_template = preload("res://Assets/Scenes/Buildings/Infestation/Infestation.tscn")

var current_health = 1000
var max_health = 1000
var is_dead = false

func deal_damage(amount):
	current_health -= amount
	if current_health < 0:
		die()
		
func die():
	is_dead = true

func _ready():
	add_to_group("cysts")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
