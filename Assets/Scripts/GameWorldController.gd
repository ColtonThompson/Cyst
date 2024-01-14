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

# Building settings
var is_building = false

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
		
	if Input.is_action_just_pressed("debug"):
		spawn_enemy_soldier(mouse_pos, 15, 100, 1, 40)

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
	if GameManager.game_over:
		return false
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

var safe_range: int = 200 # define this as the minimum distance from the player

func _get_random_spawn_position() -> Vector2:
	var camera = $Player
	var screen_rect = get_viewport().get_visible_rect().size
	var spawn_pos: = Vector2(screen_rect.x, 0).rotated(randf_range(0, 2*PI))
	return spawn_pos
	
var you_should_be_dead = false
# Controls the difficulty as time increases
func _on_enemy_spawn_timer_timeout():
	if GameManager.game_over:
		return
	var time = get_time_elapsed(GameManager.time_elapsed)
	var minutes = time[0]
	var seconds = time[1]
	var num_enemies = get_tree().get_nodes_in_group("enemies").size()
	
	# Enemy difficulty variables
	var damage = 4
	var range = 45
	var health = 35
	var move_speed = 10
	
	# Spawn related setting
	var num_to_spawn = 1

	#print("Time elapsed " + str(minutes) + " mins and " + str(seconds) + " seconds, cycles = " + str(spawn_cycles))
	# Time has hit 1 minute and 0 seconds on the clock
	if minutes == "00" and seconds == "45":
		move_speed = 11
		num_to_spawn += 2
	# Time has hit 2 minute and 0 seconds on the clock
	if minutes == "02" and seconds == "00":
		move_speed = 12	
		health = 40
		damage = 5
		num_to_spawn += 5
	# Time has hit 4 minute and 0 seconds on the clock
	if minutes == "04" and seconds == "00":
		move_speed = 14	
		health = 55
		damage = 7
	# Time has hit 7 minute and 0 seconds on the clock
	if minutes == "07" and seconds == "00":
		move_speed = 15	
		health = 70
		damage = 9
	# Time has hit 10 minute and 0 seconds on the clock
	if minutes == "10" and seconds == "00":
		move_speed = 16
		health = 85
		damage = 12
	# Time has hit 12 minute and 0 seconds on the clock
	if minutes == "12" and seconds == "00":
		move_speed = 17
		health = 100
		damage = 15
	# Time has hit 15 minute and 0 seconds on the clock
	if minutes == "15" and seconds == "00":
		move_speed = 18
		health = 150
		damage = 18
	# Time has hit 20 minute and 0 seconds on the clock
	if minutes == "20" and seconds == "00":
		you_should_be_dead = true
		move_speed = 20
		health = 200
		damage = 30
		range = 59
	if you_should_be_dead:
		health = 300
		damage += 5
	
	for i in range(num_to_spawn):
		if num_enemies >= 400:
			return
		var spawn_pos: Vector2 = _get_random_spawn_position()
		var offset: Vector2 = Vector2(randi_range(-15,15), randi_range(-15, 15))
		spawn_pos = spawn_pos + offset
		spawn_enemy_soldier(spawn_pos, move_speed, health, damage, range)
		print("Spawning basic enemy soldier at " + str(spawn_pos))
	spawn_cycles += 1

# Spawns a basic enemy soldier
func spawn_enemy_soldier(spawn_position: Vector2, move_spd, hp, dmg, attack_range):
	var soldier = enemy_soldier.instantiate()
	var offset = Vector2(randi_range(-10,10), randi_range(-10,10))
	add_child(soldier)
	soldier.set_difficulty(move_spd, hp, dmg, attack_range)
	soldier.position = spawn_position

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
	
func get_time_elapsed(time: float) -> Array:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	var format_mins := "%02d" % [minutes]
	var format_secs := "%02d" % [seconds]
	var time_result: Array = [format_mins, format_secs]
	return time_result
