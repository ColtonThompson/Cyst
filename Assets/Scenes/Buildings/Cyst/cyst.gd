extends Node2D

signal needs_to_die
signal health_changed

@onready var spore_attack = preload("res://Assets/Scenes/Buildings/Cyst/spore_attack.tscn")

var spore_attack_damage = 2
var current_health = 100
var max_health = 100
var is_dead = false
var damage_range = 60
var resource_gain_cycles_remaining = 3

@onready var infestation = $Infestation

# Object pool for floating text
var floating_text_pool: Array[FloatingText] = []
@onready var floating_text_template = preload("res://Assets/Scenes/UI/floating_text.tscn")
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

func _ready():
	add_to_group("cysts")
	
func _draw_old():
	for cyst in get_tree().get_nodes_in_group("cysts"):
		var local_cyst: Vector2 = to_local(cyst.position)
		var local_me: Vector2 = to_local(position)
		var distance = local_cyst.distance_to(local_me)
		var inverse = get_transform().affine_inverse()
		if distance < 30:
			draw_line(local_me, local_cyst, Color.ORANGE, 0.25, true)
		elif distance > GameManager.infestation_build_radius:
			draw_line(local_me, local_cyst, Color.BLUE, 0.25, true)
		elif distance >= 30 and distance <= GameManager.infestation_build_radius:
			draw_line(local_me, local_cyst, Color.GREEN, 0.25, true)

func _process(delta):
	# Better way to do this: Use a signal
	if is_dead:
		infestation.max_radius = 0
		if infestation.radius > 0:
			infestation.radius -= 3
			if infestation.radius < 0:
				infestation.radius = 0
				queue_free()
		
func deal_damage(amount):
	current_health -= amount
	health_changed.emit()
	if current_health < 0:
		die()
		
func die():
	is_dead = true
	needs_to_die.emit()

func _on_resource_gain_timer_timeout():
	if resource_gain_cycles_remaining > 0:
		var biomass_gain = ResourceManager.biomass_passive_gain
		# Gain resources passively when the timer reaches 0
		ResourceManager.gain_resource(biomass_gain)	
		create_floating_text("+" + str(biomass_gain), Vector2i(0,0))
		resource_gain_cycles_remaining -= 1

func attack_with_spores(node:Node2D):
	var offset = Vector2(randi_range(-5,5), randi_range(-5,5))
	var spore: AnimatedSprite2D = spore_attack.instantiate()
	spore.position = node.global_position + offset
	add_child(spore)
	# Hit the enemy!
	node.deal_damage(spore_attack_damage)

func _on_damage_tick_timer_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var enemy_pos = enemy.position
		var distance = position.distance_to(enemy_pos)
		if distance <= damage_range:
			attack_with_spores(enemy)
