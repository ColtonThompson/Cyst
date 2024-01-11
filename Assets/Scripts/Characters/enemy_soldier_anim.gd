extends AnimatedSprite2D

var is_moving = false
var is_in_combat = false
var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
