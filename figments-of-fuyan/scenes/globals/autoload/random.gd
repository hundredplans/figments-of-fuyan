class_name Random

static func setSeed(_my_seed: int) -> void:
	seed(1)

static func getRandomKey(odds: Dictionary) -> String:
	var roll: float = randf()
	var total: float = 0
	for key in odds:
		if roll < odds[key] + total: return key
		total += odds[key]
	return odds[odds.size() - 1]
	
static func onConvertPercentOdds(odds: Dictionary) -> Dictionary:
	var new_odds: Dictionary = {}
	for key in odds.keys():
		new_odds[key] = (odds[key] / 100)
	return new_odds

static func getBool() -> bool:
	return randf() > 0.5

static func rollFloat(x: float) -> bool:
	return x > randf()
