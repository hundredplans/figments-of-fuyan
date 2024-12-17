class_name Loner extends Behaviour

const DISTANCE_TO_VALUE: Dictionary = {
	1: 0,
	2: 0.2,
	3: 0.75,
	# 4 or greater is 1
}

func getOutOfCombatTiles(_Card: CardGD, tiles: Array, allies: Array) -> Dictionary:
	var tiles_by_value: Dictionary = {}
	for Tile in tiles:
		tiles_by_value[Tile] = 0
		for ally in allies:
			var distance: int = Game.getCoordsDistance(Tile.getCoords(), ally.getCoords())
			var value: float = DISTANCE_TO_VALUE[distance] if distance < 4 else 1.0
			tiles_by_value[Tile] += value
		
		if allies.size() > 0:
			tiles_by_value[Tile] /= allies.size()
	return tiles_by_value
