class_name Teamer extends Behaviour

func getOutOfCombatTiles(_Card: CardGD, tiles: Array, allies: Array, _enemies: Array) -> Dictionary: 
	var tiles_by_value: Dictionary = {}
	var max_distance: float = 0.0
	for Tile: TileGD in tiles:
		var min_distance: int = allies.map(func(x: CardGD): return Game.getCoordsDistance(Tile.getCoords(), x.getCoords())).min()
		tiles_by_value[Tile] = min_distance
		if min_distance > max_distance:
			max_distance = min_distance
			
	for Tile: TileGD in tiles:
		tiles_by_value[Tile] -= 1
		tiles_by_value[Tile] /= max_distance
		tiles_by_value[Tile] = abs(tiles_by_value[Tile] - 1)
	return tiles_by_value

func isOutOfCombatBehaviour() -> bool:
	return true

func isCombatBehaviour() -> bool:
	return false
