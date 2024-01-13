extends Node2D

@onready var bg_music = $BackgroundMusic
@onready var hive = $Hive
@onready var pause_control = $UI/PauseControl
# Error Message Animation
var error_message_template = preload("res://Assets/Scenes/UI/error_message.tscn")

# Enemy instance
var enemy_soldier = preload("res://Assets/Scenes/Characters/enemy_soldier.tscn")

# Buildings that can be placed, we preload them to instantiate them later
var building_cyst = preload("res://Assets/Scenes/Buildings/Cyst/cyst.tscn")

# reference to the hive so we can set a game over condition
@onready var hive_building = $Hive
@onready var game_over_control = $UI/GameOverControl
@onready var build_cyst_button = $UI/HUDControl/ButtonControl/BuildCystButton

var is_building = false

var last_placed_positions: Array = []

# This is the popup message when you can't do something and need context for it
var error_message: String = ""

# Signals
signal info_signal

# This number will increase each time the EnemySpawnTimer reaches a timeout(), we will use this to increase difficulty!
var spawn_cycles = 0

func _ready():
	bg_music.set_volume_db(-5)
	reset_game()

func _input(event):
	var mouse_pos = get_global_mouse_position()

	#if Input.is_action_just_pressed("pause_game"):
		#print("Game state paused = " + str(get_tree().paused))
		#get_tree().paused = !get_tree().paused
		#pause_control.set_visible(!pause_control.visible)

	# Building mode toggle
	if Input.is_action_just_pressed("toggle_building_mode"):
		is_building = true

	if Input.is_action_just_pressed("restart_game"):
		if GameManager.game_over:
			get_tree().reload_current_scene()
	
	# Building placement
	if is_building:
		if Input.is_action_just_pressed("place_building"):
			create_building("CYST", mouse_pos)

func _process(delta):
	$UI/KillControl/KillCountLabel.text = "Kills: " + str(GameManager.kills)
	$UI/KillControl/EnemyCountLabel.text = "Enemies: " + str(get_tree().get_nodes_in_group("enemies").size())

# Used to display error message to inform the player what is going on
func display_error(message: String, color: Color):
	var new_message = error_message_template.instantiate()
	add_child(new_message)
	new_message.set_values_and_animate(message, color)	

# Creates a building object and adds it to a building dictionary to be managed		
func create_building(building_name, mouse_position):
	var now = Time.get_ticks_msec()
	var time_passed = now - GameManager.last_building_placed
	if time_passed < 500:
		return
	if !can_place_building(building_name, mouse_position):
		return
	var resource_cost = ResourceManager.get_building_cost(building_name)
	# Set the timer for delay
	GameManager.last_building_placed = Time.get_ticks_msec()
	match building_name:
		"CYST":
			ResourceManager.spend_resource(resource_cost)
			var cyst_instance = building_cyst.instantiate()
			hive.add_child(cyst_instance, true)
			cyst_instance.set_position(get_global_mouse_position())
		_:
			print("Unexpected building trying to be placed!")
			
# Determines if the player can place the building
# Checks resource cost and if the position is good
func can_place_building(building_name, mouse_position):
	var resource_cost = ResourceManager.get_building_cost(building_name)
	# Check to make sure the player has enough resources to place the building
	if ResourceManager.biomass < resource_cost || resource_cost == -1:
		display_error("Unable to place building! Not enough Biomass!", Color.RED)
		return false
	# Check logic for each building type incase of special rules
	match building_name:
		"CYST":
			for cyst in hive.get_tree().get_nodes_in_group("cysts"):
				if cyst == null:
					continue
				var distance = cyst.global_position.distance_to(get_global_mouse_position())
				if distance < 20:
					display_error("Unable to place Cyst! Too close to another Cyst!", Color.RED)
					return false
					
			var closest_cyst = get_nearest_cyst(get_global_mouse_position())
			var dist_to_closest = closest_cyst.global_position.distance_to(get_global_mouse_position())
			if dist_to_closest > GameManager.infestation_build_radius:
				display_error("Unable to place Cyst! Too far from the Cyst network!", Color.RED)
				return false
			return true
	
func get_nearest_cyst(position: Vector2):
	var closest_distance = 1000
	var closest_cyst:Node2D
	var cysts = get_tree().get_nodes_in_group("cysts")
	for cyst in cysts:
		var distance = position.distance_to(cyst.position)
		if distance < closest_distance:
			closest_distance = distance
			closest_cyst = cyst
	return closest_cyst
	
# Resets the game variables to defaults 	
func reset_game():
	ResourceManager.biomass = ResourceManager.biomass_starting_value
	ResourceManager.biomass_passive_gain = ResourceManager.biomass_passive_gain_starting_value
	GameManager.time_elapsed = 0
	GameManager.game_over = false
		
func arrange_in_circle(n: int, r: float, center=Vector2.ZERO, start_offset=0.0) -> Array:
	var output = []
	var offset = 2.0 * PI / abs(n) # could verify that n is non-zero and
	var theta = 100
	for i in range(n):
		# Convert polar to cartesian
		var x = r * cos(theta);
		var y = r * sin(theta);
		var pos = Vector2(x,y)
		output.push_front(pos + center)
	return output

var safe_range: int = 250 # define this as the minimum distance from the player

func _get_random_spawn_position() -> Vector2:
	var camera = $Player
	var spawn_pos: = Vector2(safe_range, 0).rotated(randf_range(-(2*PI), 2*PI))
	var distance = camera.position.distance_to(spawn_pos)
	if distance < safe_range: # if we are too close
		spawn_pos = _get_random_spawn_position() # just get a new one instead
	return spawn_pos
	
# Controls the difficulty as time increases
func _on_enemy_spawn_timer_timeout():
	var num_enemies = get_tree().get_nodes_in_group("enemies").size()
	if num_enemies >= GameManager.max_enemies:
		return
	$EnemySpawnTimer.set_wait_time(3.0)	
	var move_speed = 8
	var health = 55
	var damage = 5
	var range = 40
	if spawn_cycles % 2 == 0:
		damage += 1
		if GameManager.max_enemies < 400:
			GameManager.max_enemies += 5
		GameManager.num_enemies_to_spawn += randi_range(3, 8)
	elif spawn_cycles % 3 == 0:
		if range < 60:
			range += 1
		health += 15
		damage += 1
		if GameManager.max_enemies < 400:
			GameManager.max_enemies += 15
		GameManager.num_enemies_to_spawn += randi_range(8, 16)	
	elif spawn_cycles % 4 == 0:
		if GameManager.max_enemies < 400:
			GameManager.max_enemies += 30
		GameManager.num_enemies_to_spawn += randi_range(16, 32)		
	elif spawn_cycles % 10 == 0:
		if safe_range < 750:
			safe_range += 100
		move_speed = 10
		if GameManager.max_enemies < 400:
			GameManager.max_enemies += 75
		GameManager.num_enemies_to_spawn += randi_range(32, 64)	
		
	for i in range(GameManager.num_enemies_to_spawn):
		var position: Vector2 = _get_random_spawn_position()
		var offset: Vector2 = Vector2(randi_range(-5,10), randi_range(-5,10))
		var soldier = enemy_soldier.instantiate()
		add_child(soldier, true)
		
		soldier.set_difficulty(move_speed, health, damage, range)
		soldier.position = position + offset
		spawn_cycles += 1

func _on_build_cyst_button_pressed():
	if is_building:
		is_building = false
	else:
		is_building = true

func _on_hive_hive_has_died():
	game_over_control.visible = true
	GameManager.game_over = true

func _on_resume_button_pressed():
	get_tree().paused = false
	pause_control.set_visible(false)
