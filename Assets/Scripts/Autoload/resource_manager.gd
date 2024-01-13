extends Node

# Resources
var biomass = 400
var biomass_starting_value = 400
# This variable is to create a counting effect for when you gain/spend resources (like starcraft)
var biomass_spent = 0
# How much biomass you generate for each cyst every 3 seconds
var biomass_passive_gain = 5
var biomass_passive_gain_starting_value = 8
# Dict to store all the building resource costs
var building_costs := { "CYST": 75 }

func spend_resource(amount):
	biomass -= amount
	
func gain_resource(amount):
	if biomass >= 10000:
		return
	biomass += amount

# Gets the cost of a building!
func get_building_cost(building_name) -> int:
	for key in building_costs:
		if building_name.nocasecmp_to(key) == 0: # Case insensitive compare (0 = equals)
			return building_costs[key]
	return -1
