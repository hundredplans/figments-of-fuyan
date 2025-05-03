class_name RarityOddsDatastore extends Resource

@export_range(0, 100, 0.1) var common: float
@export_range(0, 100, 0.1) var rare: float
@export_range(0, 100, 0.1) var exalt: float
@export_range(0, 100, 0.1) var miniboss: float
@export_range(0, 100, 0.1) var boss: float

func getDictionary() -> Dictionary:
	var dict: Dictionary = {}
	if common > 0: dict[Game.Rarities.COMMON] = common
	if rare > 0: dict[Game.Rarities.RARE] = rare
	if exalt > 0: dict[Game.Rarities.EXALT] = exalt
	if miniboss > 0: dict[Game.Rarities.MINIBOSS] = miniboss
	if boss > 0: dict[Game.Rarities.BOSS] = boss
	assert(dict.values().reduce((func(accum: float, number: float): return accum + number), 0) >= 100)
	return dict
