extends Camera2D

var camera_move_speed = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_left"):
		position.x -= camera_move_speed * delta
	elif Input.is_action_just_pressed("ui_right"):
		position.x += camera_move_speed * delta
		
	if Input.is_action_just_pressed("ui_up"):
		position.y -= camera_move_speed * delta
	elif Input.is_action_just_pressed("ui_down"):
		position.y += camera_move_speed * delta
