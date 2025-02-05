extends Behaviour

const ACCEPTER_MULTIPLIER: int = 3 # Tiles are a +3

func isOutOfCombatBehaviour() -> bool:
	return true

func isCombatBehaviour() -> bool:
	return false

func getOutOfCombatTiles(Card: CardGD, tiles: Array, _allies: Array, _enemies: Array) -> Dictionary:
	var enemy_tiles: Array = Card.ai_datastore.getEnemyTiles()
	var tiles_by_value: Dictionary = {}
	var max_distance: int
	for Tile in tiles:
		var total_distance: int = enemy_tiles.map(func(x: TileGD): return Game.getCoordsDistance(x.getCoords(), Tile.getCoords())).reduce(sum, 0)
		tiles_by_value[Tile] = total_distance
		
		if total_distance > max_distance:
			max_distance = total_distance
		
	for Tile in tiles_by_value:
		tiles_by_value[Tile] /= float(max_distance)
		tiles_by_value[Tile] = abs(tiles_by_value[Tile] - 1)
		tiles_by_value[Tile] *= ACCEPTER_MULTIPLIER
	return tiles_by_value
	
func getCombatTiles(_Card: CardGD, _tiles: Array, _attackables: Array, _allies: Array) -> Dictionary:
	return {}

func sum(accum: int, value: int) -> int:
	return accum + value
