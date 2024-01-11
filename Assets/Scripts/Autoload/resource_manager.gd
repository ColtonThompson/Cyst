extends Node

# Resources
var biomass = 300
var biomass_starting_value = 300
# This variable is to create a counting effect for when you gain/spend resources (like starcraft)
var biomass_spent = 0
# How much biomass you generate for each cyst every 3 seconds
var biomass_passive_gain = 5
var biomass_passive_gain_starting_value = 5
# Dict to store all the building resource costs
var building_costs := { "CYST": 100 }

func spend_resource(amount):
	biomass -= amount
	biomass_spent = amount
	
func gain_resource(amount):
	biomass += amount
	biomass_spent -= amount

# Gets the cost of a building!
func get_building_cost(building_name) -> int:
	for key in building_costs:
		if building_name.nocasecmp_to(key) == 0: # Case insensitive compare (0 = equals)
			return building_costs[key]
	return -1
