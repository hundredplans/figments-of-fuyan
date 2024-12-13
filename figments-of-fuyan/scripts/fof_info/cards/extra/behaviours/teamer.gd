class_name Teamer extends Behaviour

const MAX_ALLY: int = 3
const DISTANCE_TO_VALUE: Dictionary = {
	1: 0.5,
	2: 1,
	3: 0.5,
	4: 0.25,
	# 5 or greater is 0
}

func getOutOfCombatTiles(_Card: CardGD, tiles: Array, allies: Array) -> Dictionary: 
	var tiles_by_value: Dictionary = {}
	for Tile in tiles:
		tiles_by_value[Tile] = 0
		for ally in allies:
			var distance: int = Game.getCoordsDistance(Tile.getCoords(), ally.getCoords())
			if distance >= 5: continue
			
			tiles_by_value[Tile] = min(tiles_by_value[Tile] + DISTANCE_TO_VALUE[distance], MAX_ALLY)
		tiles_by_value[Tile] /= MAX_ALLY
	return tiles_by_value
