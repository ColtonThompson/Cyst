extends Node

var time_elapsed: float = 0.0
var buildings = {}

# Basic building variables 
var building_mode = false
var last_building_placed = 0
var selected_building = "NONE"
var infestation_radius = 50

var game_over = false

func get_time_elapsed() -> float:
	return time_elapsed

func add_building(building_name, position):
	if !buildings.has(position):
		buildings[position] = building_name
		
