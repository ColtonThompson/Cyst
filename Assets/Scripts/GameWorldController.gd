extends Node2D

@onready var info_label = $UI/InfoControl/InfoLabel

# Enemy instance
var enemy_soldier = preload("res://Assets/Scenes/Characters/enemy_soldier.tscn")

# Buildings that can be placed, we preload them to instantiate them later
var building_cyst = preload("res://Assets/Scenes/Buildings/Cyst/cyst.tscn")
# reference to the hive so we can set a game over condition
@onready var hive_building = $Hive
@onready var game_over_control = $UI/GameOverControl

# This is the popup message when you can't do something and need context for it
var error_message: String = ""

# Signals
signal info_signal

func _ready():
	reset_game()

func _input(event):
	var mouse_pos = get_global_mouse_position()
	
	# Building mode toggle
	if Input.is_action_just_pressed("toggle_building_mode"):
		if GameManager.building_mode:
			GameManager.building_mode = false
		else:
			GameManager.building_mode = true
		print("Building mode toggled " + str(GameManager.building_mode))
	
	if Input.is_action_just_pressed("restart_game"):
		if GameManager.game_over:
			get_tree().reload_current_scene()
	
	# Enemy debugging!
	if Input.is_action_just_pressed("spawn_enemy"):
		var soldier = enemy_soldier.instantiate()
		add_child(soldier, true)
		soldier.position = get_global_mouse_position()
		
	# Building placement
	if GameManager.building_mode:
		if Input.is_action_just_pressed("place_building"):
			create_building("CYST", mouse_pos)

func _process(delta):
	# Trigger end of game!
	if hive_building.current_health <= 0 and hive_building.is_dead:
		game_over_control.visible = true
		GameManager.game_over = true

# Creates a building object and adds it to a building dictionary to be managed		
func create_building(building_name, position):
	var now = Time.get_ticks_msec()
	var time_passed = now - GameManager.last_building_placed
	if time_passed < 300:
		print("Trying to build too fast!")
		return
	if !can_place_building(building_name, position):
		print("Can't place building!")
		return
	var resource_cost = ResourceManager.get_building_cost(building_name)
	# Set the timer for delay
	GameManager.last_building_placed = Time.get_ticks_msec()
	match building_name:
		"CYST":
			var instance = building_cyst.instantiate()
			add_child(instance)
			instance.position = position
			ResourceManager.spend_resource(resource_cost)
			GameManager.add_building(building_name, position)
		_:
			print("Unexpected building trying to be placed!")
			
# Determines if the player can place the building
# Checks resource cost and if the position is good
# TODO: Check collision with other buildings to prevent stacking	
func can_place_building(building_name, position):
	var resource_cost = ResourceManager.get_building_cost(building_name)
	# Check to make sure the player has enough resources to place the building
	if ResourceManager.biomass < resource_cost || resource_cost == -1:
		display_error("Unable to place building! Not enough Biomass!")
		return false
	# Check logic for each building type incase of special rules
	match building_name:
		"CYST":
			var cysts = get_tree().get_nodes_in_group("cysts")
			for cyst in cysts:
				var cyst_pos = cyst.position
				var distance = position.distance_to(cyst_pos)
				if distance > GameManager.infestation_radius:
					continue
				if distance <= GameManager.infestation_radius:
					return true			
	return false

# Sets the text for info_label and emits a signal for it to be shown
func display_error(text):
	info_label.text = text
	info_signal.emit()

# Resets the game variables to defaults 	
func reset_game():
	ResourceManager.biomass_spent = 0
	ResourceManager.biomass = ResourceManager.biomass_starting_value
	ResourceManager.biomass_passive_gain = ResourceManager.biomass_passive_gain_starting_value
	GameManager.time_elapsed = 0
	GameManager.game_over = false
	
