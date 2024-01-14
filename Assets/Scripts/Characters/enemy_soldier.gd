extends CharacterBody2D

@onready var bullet_template = preload("res://Assets/Scenes/Projectiles/bullet.tscn")
@onready var anim = $AnimatedSprite2D
@onready var attack_delay_timer = $AttackDelayTimer
@onready var shooting_node = $ShootingPosition

# Spore attack animation
@onready var spores = $SporeAttack

# Object pool for floating text
var floating_text_pool: Array[FloatingText] = []
@onready var floating_text_template = preload("res://Assets/Scenes/UI/floating_text.tscn")

# Difficulty variables
@export var move_speed = 12

# Attack speed in seconds (delay)
@export var attack_speed = 1
@export var attack_damage = 5
@export var attack_range = 30

@export var max_health = 50
var current_health = max_health

var target_node: Node2D
var is_in_combat = false
var can_fire = true
var is_dead = false
var is_buffed = false

# Tracking behavior states
var behaviour_state = "IDLE"

func _ready():
	# Set attack delay to the variable value
	attack_delay_timer.set_wait_time(attack_speed)
	add_to_group("enemies")
	
func set_difficulty(speed: int, health:int, damage:int, range:int, buffed:bool):
	move_speed = speed
	max_health = health
	current_health = health
	attack_damage = damage
	attack_range = range
	is_buffed = buffed
	
# Creates floating text with value at start_pos
func create_floating_text(value, start_pos):
	var floating_text = get_floating_text()
	add_child(floating_text, true)
	floating_text.set_values_and_animate(value, start_pos, 15, 5, Color.PURPLE)

# Gets a new floating text object or pulls one from a pool
func get_floating_text() -> FloatingText:
	if floating_text_pool.size() > 0:
		return floating_text_pool.pop_front()
	else:
		var new_floating_text = floating_text_template.instantiate()
		new_floating_text.tree_exiting.connect(func():floating_text_pool.append(new_floating_text))
		return new_floating_text

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
		var potential_new_target = find_nearest_target()
		if potential_new_target != target_node:
			target_node = potential_new_target
		if !is_within_attack_distance(target_node.position, attack_range):
			update_animation()
			move_towards_target(get_process_delta_time())
		else:
			behaviour_state = "ATTACK"
			update_animation()
			attack_target()
		
# Called every frame
func _process(delta):
	sprite_buffed()

# Called on a static delay for physics calculations/movement
func _physics_process(delta):
	handle_behaviour()
	
func sprite_buffed() -> void:
	if is_buffed:
		anim.modulate = Color("#ff7615", 1)

func sprite_flash() -> void:
	var tween: Tween = create_tween()
	#tween.tween_property(anim, "modulate:v", 1, 0.25).from(15)
	if tween != null:
		tween.tween_property(anim, "modulate:v", 1, 0.25).from(5)
	
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
		
func set_target(target: Node2D):
	target_node = target

# Looks for the closest target to attack
func find_nearest_target() -> Node2D:
	var lowest_val = 10000
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

func show_spore_attack():
	if !spores.visible:		
		var range = 5
		var spore_pos = Vector2(randi_range(-range,range), randi_range(-range,range))
		spores.visible = true
		spores.reload_and_play(spore_pos)
		
func deal_damage(amount):
	show_spore_attack()
	sprite_flash()
	current_health -= amount
	if current_health < 0:
		die()
		
func die():
	if behaviour_state == "DEAD":
		queue_free()
		return
	GameManager.kills += 1
	if is_buffed:
		ResourceManager.biomass += 21
		create_floating_text("+21", Vector2.ZERO)
	else:
		ResourceManager.biomass += 12
		create_floating_text("+12", Vector2.ZERO)
	is_dead = true
	behaviour_state = "DEAD"
	anim.play("dead")
	
func _on_debug_timer_timeout():
	pass
