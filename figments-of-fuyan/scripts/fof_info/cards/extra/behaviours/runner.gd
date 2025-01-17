class_name Runner extends Behaviour

func getCombatTiles(_Card: CardGD, tiles: Array, attackables: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	for Tile in tiles:
		var distance: int = attackables.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), Tile.getCoords())).min()
		tiles_to_value[Tile] = distance
		
	var max_distance: int = tiles_to_value.values().max()
	for Tile in tiles_to_value:
		tiles_to_value[Tile] /= max_distance
	
	return tiles_to_value
