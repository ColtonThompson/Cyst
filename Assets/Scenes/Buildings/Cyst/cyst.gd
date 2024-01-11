extends Node2D

signal needs_to_die

@onready var spore_attack = preload("res://Assets/Scenes/Buildings/Cyst/spore_attack.tscn")

var current_health = 100
var max_health = 100
var is_dead = false
var damage_range = 45

@onready var infestation_template = preload("res://Assets/Scenes/Buildings/Infestation/Infestation.tscn")
@onready var infestation = $Infestation
# Object pool for floating text
var floating_text_pool: Array[FloatingText] = []
@onready var floating_text_template = preload("res://Assets/Scenes/UI/floating_text.tscn")

func _ready():
	add_to_group("cysts")

func _process(delta):
	# Better way to do this: Use a signal
	if is_dead:
		infestation.max_radius = 0
		if infestation.radius > 0:
			infestation.radius -= 3
			if infestation.radius < 0:
				infestation.radius = 0
				queue_free()

# Creates floating text with value at start_pos
func create_floating_text(value, start_pos):
	var floating_text = get_floating_text()
	add_child(floating_text, true)
	floating_text.set_values_and_animate(value, start_pos, 15, 5)

# Gets a new floating text object or pulls one from a pool
func get_floating_text() -> FloatingText:
	if floating_text_pool.size() > 0:
		return floating_text_pool.pop_front()
	else:
		var new_floating_text = floating_text_template.instantiate()
		new_floating_text.tree_exiting.connect(func():floating_text_pool.append(new_floating_text))
		return new_floating_text
		
func deal_damage(amount):
	current_health -= amount
	if current_health < 0:
		die()
		
func die():
	is_dead = true
	needs_to_die.emit()

func _on_resource_gain_timer_timeout():
	var biomass_gain = ResourceManager.biomass_passive_gain
	# Gain resources passively when the timer reaches 0
	ResourceManager.gain_resource(biomass_gain)	
	create_floating_text("+" + str(biomass_gain), Vector2i(0,0))

func attack_with_spores(node:Node2D):
	var spore: AnimatedSprite2D = spore_attack.instantiate()
	spore.position = node.global_position
	add_child(spore)
	# Hit the enemy!
	node.deal_damage(3)

func _on_damage_tick_timer_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var enemy_pos = enemy.position
		var distance = position.distance_to(enemy_pos)
		if distance <= damage_range:
			attack_with_spores(enemy)
