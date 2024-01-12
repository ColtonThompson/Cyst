extends CharacterBody2D

@onready var timer = $Timer

var bullet_speed = 400
var bullet_damage = 1
var target: Node2D

func _ready():
	pass

# Sets the initial values 
func set_values(node: Node2D, damage: float, speed: float):
	target = node
	bullet_damage = damage
	bullet_speed = speed
	var direction = position.direction_to(target.position)
	set_as_top_level(true)
	look_at(position + direction)
	timer.start()
	
func move_towards_target(delta):
	if target == null:
		return
	var direction = position.direction_to(target.position)
	velocity = direction * bullet_speed
	move_and_collide(velocity * delta)

func _physics_process(delta):
	move_towards_target(delta)

func _on_input_event(viewport, event, shape_idx):
	print("Bullet collided with object!")
	timer.start()

func _on_timer_timeout():
	queue_free()
