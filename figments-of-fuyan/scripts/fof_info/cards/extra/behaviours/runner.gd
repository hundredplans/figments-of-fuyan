class_name Runner extends Behaviour

const OUTNUMBER_ADVANTAGE: int = 2

func getCombatTiles(_Card: CardGD, tiles: Array, enemies: Array, _allies: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	var max_distance: float = 0
	for Tile: TileGD in tiles:
		var min_distance: float = getMinAttackDistanceFromInAttackableRange(Tile, enemies)
		if min_distance > max_distance:
			max_distance = min_distance
		tiles_to_value[Tile] = min_distance
		
	for Tile: TileGD in tiles.filter(func(x: TileGD): return tiles_to_value[x] > 0.9): # 1 or greaterr
		tiles_to_value[Tile] -= 1 # So one away becomes 0, when the flip happens this makes it work better
		tiles_to_value[Tile] /= max_distance
		tiles_to_value[Tile] = abs(tiles_to_value[Tile] - 1)
		
	return tiles_to_value

func getMinAttackDistanceFromInAttackableRange(Tile: TileGD, enemies: Array) -> float:
	return enemies.map(func(x: CardGD): return max(Game.getCoordsDistance(Tile.getCoords(), x.getCoords()) - (x.speed + x.getAttackRange()), 0)).min()

func isOutOfCombatBehaviour() -> bool:
	return false

func isCombatBehaviour() -> bool:
	return true
