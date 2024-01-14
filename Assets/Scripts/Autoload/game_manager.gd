extends Node

var time_elapsed: float = 0.0

var game_over = false

# Basic building variables 
var last_building_placed = 0
var selected_building = "NONE"
var infestation_radius = 50
var infestation_build_radius = 65

# Session stats
var kills = 0

# Cyst network
var cyst_network: Array = []

func add_cyst_to_network(node):
	cyst_network.append(node)
	
func get_cysts_in_network() -> Array:
	return cyst_network

func get_time_elapsed() -> float:
	return time_elapsed
