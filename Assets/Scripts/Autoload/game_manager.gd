extends Node

var time_elapsed: float = 0.0

# Basic building variables 
var last_building_placed = 0
var selected_building = "NONE"
var infestation_radius = 50
var infestation_build_radius = 65

# Difficulty settings
var num_enemies_to_spawn = 1
var max_enemies = 5
var kills = 0

var game_over = false

func get_time_elapsed() -> float:
	return time_elapsed
