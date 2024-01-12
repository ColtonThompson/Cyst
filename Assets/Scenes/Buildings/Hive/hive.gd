extends Node2D

var current_health = 1000
var max_health = 1000
var is_dead = false

signal health_changed
signal hive_has_died

func deal_damage(amount):
	current_health -= amount
	health_changed.emit()
	if current_health < 0:
		die()
		
func die():
	hive_has_died.emit()
	is_dead = true

func _ready():
	add_to_group("cysts")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
