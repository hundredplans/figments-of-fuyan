extends Node

func setSeed(my_seed: int) -> void:
	seed(1)

func getRandomKey(odds: Dictionary) -> String:
	var roll: float = randf()
	var total: float = 0
	for key in odds:
		if roll < odds[key] + total: return key
		total += odds[key]
	assert(false, "Your random numbers don't add up to one!")
	return ""

func getBool() -> bool:
	return randf() > 0.5

func rollFloat(x: float) -> bool:
	return x > randf()
