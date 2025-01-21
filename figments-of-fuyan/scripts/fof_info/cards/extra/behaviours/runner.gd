class_name Runner extends Behaviour

const OUTNUMBER_ADVANTAGE: int = 2

func getCombatTiles(Card: CardGD, tiles: Array, enemies: Array, allies: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	
	if !(allies.size() >= enemies.size() + OUTNUMBER_ADVANTAGE):
		for Tile in tiles:
			var distance: int = enemies.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), Tile.getCoords())).min()
			tiles_to_value[Tile] = distance
			
		var max_distance: float = max(tiles_to_value.values().max() if !tiles_to_value.is_empty() else 1, 1)
		for Tile in tiles_to_value:
			tiles_to_value[Tile] /= max_distance
	else:
		var attack_range: int = Card.getAttackRange()
		for Tile in tiles:
			var distance: float = enemies.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), Tile.getCoords())).min() - attack_range
			distance = max(distance, 1)
			tiles_to_value[Tile] = 1.0 / distance
	return tiles_to_value

func isOutOfCombatBehaviour() -> bool:
	return false

func isCombatBehaviour() -> bool:
	return true
