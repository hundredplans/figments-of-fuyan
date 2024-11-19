class_name RarityPriceDatastore extends Resource

@export_range(0, 100, 1) var common: int
@export_range(0, 100, 1) var rare: int
@export_range(0, 100, 1) var exalt: int
@export_range(0, 100, 1) var miniboss: int
@export_range(0, 100, 1) var boss: int

func getByRarity(rarity: Game.Rarities) -> int:
	return get(Game.getRarityString(rarity).to_lower())
		
