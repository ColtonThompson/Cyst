extends CharacterBody2D

@onready var bullet_template = preload("res://Assets/Scenes/Projectiles/bullet.tscn")
@onready var anim = $AnimatedSprite2D
@onready var attack_delay_timer = $AttackDelayTimer
@onready var shooting_node = $ShootingPosition

var move_speed = 5
var current_health = 45
var max_health = 45
var attack_speed = 1
var attack_damage = 5
var attack_range = 45

var target_node: Node2D
var is_in_combat = false
var can_fire = true
var is_dead = false

# Tracking behavior states
var behaviour_state = "IDLE"

func _ready():
	add_to_group("enemies")

func _on_attack_delay_timer_timeout():
	# allow the soldier to fire again
	can_fire = true
	
	# Check if the target was removed from the scene or if it died
	if target_node == null:
		reset_behaviour()
		return
	elif target_node.is_dead:
		reset_behaviour()
		return
		
	# If we are still attacking the target, attack again
	if behaviour_state == "ATTACK":
		attack_target()

# Handles the logic of the NPC
func handle_behaviour():
	if GameManager.game_over:
		return
	# We are IDLE and we need to find a target to kill!
	if behaviour_state == "IDLE":
		target_node = find_nearest_target()
		if target_node == null:
			reset_behaviour()
			return
		# Make sure target isn't already dead
		if !target_node.is_dead:
			# Target isn't dead, now we check distance
			# If the distance is outside of our attack range, we need to move closer
			if is_within_attack_distance(target_node.position, attack_range):
				behaviour_state = "ATTACK"
				update_animation()
				attack_target()
			else:
				behaviour_state = "MOVING"
		else: # Target is dead, we need to reset and find a new target
			reset_behaviour()	
	elif behaviour_state == "MOVING":
		if target_node == null:
			reset_behaviour()
			return
		if !is_within_attack_distance(target_node.position, attack_range):
			update_animation()
			move_towards_target(get_process_delta_time())
		else:
			behaviour_state = "ATTACK"
			update_animation()
			attack_target()
		
# Called every frame
func _process(delta):
	pass
	#queue_redraw()

# Called on a static delay for physics calculations/movement
func _physics_process(delta):
	handle_behaviour()
	
func update_animation():
	var target_position = target_node.position
	var diff_x = target_position.x - position.x
	var diff_y = target_position.y - position.y
	
	if diff_x < 0: # Face left
		anim.flip_h = true
	elif diff_x > 0: # Face right
		anim.flip_h = false
		
	# Play the animations needed
	if behaviour_state == "MOVING":
		anim.play("move")
	elif behaviour_state == "ATTACK":
		anim.play("attack")
	elif !is_dead:
		anim.play("idle")
		
# Debugging to show target / attack range logic
func _draw_old():
	if target_node == null:
		return
	var distance = position.distance_to(target_node.position)
	if distance > attack_range:
		draw_line(to_local(position), to_local(target_node.position), Color.RED, 0.25, true)
	else:
		draw_line(to_local(position), to_local(target_node.position), Color.GREEN, 0.25, true)

func set_target(target: Node2D):
	target_node = target

# Looks for the closest target to attack
func find_nearest_target() -> Node2D:
	var lowest_val = 1000
	var target_node: Node2D
	var cysts = get_tree().get_nodes_in_group("cysts")
	for cyst in cysts:
		var cyst_pos = cyst.position
		var distance = position.distance_to(cyst_pos)
		if distance < lowest_val:
			lowest_val = distance
			target_node = cyst
	return target_node
	
func is_within_attack_distance(target:Vector2i, attack_range: int) -> bool:
	return position.distance_to(target) <= attack_range
	
func move_towards_target(delta):
	if is_in_combat:
		return
	var direction = position.direction_to(target_node.position)
	var distance = position.distance_to(target_node.position)
	var max_speed = move_speed
	velocity = direction * minf(move_speed, max_speed)
	move_and_slide()
	
func attack_target():
	if target_node == null:
		reset_behaviour()
		return	
	if !is_in_combat:
		is_in_combat = true
		update_animation()

	var target_health = target_node.current_health
	var target_max_health = target_node.max_health
	# Target isn't dead!
	if !target_node.is_dead:
		if can_fire:
			target_node.deal_damage(attack_damage)
			shoot_bullet(target_node, attack_damage, 100)
			attack_delay_timer.start()
			can_fire = false
	else:
		reset_behaviour()

# Instantiates a bullet into the scene and is given a target, damage and speed values
func shoot_bullet(node: Node2D, damage: float, speed: float):
	var bullet = bullet_template.instantiate()
	add_child(bullet)
	bullet.position = shooting_node.global_position
	bullet.rotation = get_angle_to(node.global_position)
	bullet.set_values(node, attack_damage, speed)
				
func reset_behaviour():
	behaviour_state = "IDLE"
	is_in_combat = false
	target_node = null
	
func deal_damage(amount):
	current_health -= amount
	if current_health < 0:
		die()
		
func die():
	if behaviour_state == "DEAD":
		queue_free()
		return
	is_dead = true
	behaviour_state = "DEAD"
	anim.play("dead")
	
func _on_debug_timer_timeout():
	pass
