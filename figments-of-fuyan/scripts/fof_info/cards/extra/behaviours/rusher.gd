class_name Rusher extends Behaviour

func getCombatTiles(Card: CardGD, tiles: Array, attackables: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	var attack_range: int = Card.getAttackRange()
	for Tile in tiles:
		var distance: int = attackables.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), Tile.getCoords())).min() - attack_range
		distance = max(distance, 0)
		tiles_to_value[Tile] = 1.0 / distance
	return tiles_to_value
