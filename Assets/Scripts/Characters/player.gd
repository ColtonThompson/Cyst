extends CharacterBody2D

var input = Vector2.ZERO

const max_speed = 125
const accel = 5000
const friction = 1500

# Handles the input events 
func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()

func handle_movement(delta):
	input = get_input()

	# No input
	if input == Vector2.ZERO:
		# If we are moving, we should start slowing down
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		# Not moving so we are stopped
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
		
	move_and_slide()
	
# Updates every frame
func _physics_process(delta):
	handle_movement(delta)
