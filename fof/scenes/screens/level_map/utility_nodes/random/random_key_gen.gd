class_name RandomKeyGenGD
extends Resource

# Odds should up to 1
var keys_odds: Dictionary = {}
func _init(keys: Array, odds: Array) -> void:
	var odd_total: float = 0
	for i in range(keys.size()):
		keys_odds[keys[i]] = odds[i]
		odd_total += odds[i]
	
	if odd_total < 0.999: keys_odds["NULL"] = 1 - odd_total
	

func onRoll() -> String:
	var total: float = 0
	var roll: float = randf()
	
	for key in keys_odds:
		total += keys_odds[key]
		if roll < total: return key
	return ""
