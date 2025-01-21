class_name Explorer extends Behaviour

func getOutOfCombatTiles(Card: CardGD, tiles: Array, _allies: Array, _enemies: Array) -> Dictionary:
	var tiles_by_value: Dictionary = {}
	for Tile in tiles:
		tiles_by_value[Tile] = 0 if Tile.explored.getExploredByTeam(Card.team) else 1
	return tiles_by_value

func isOutOfCombatBehaviour() -> bool:
	return true

func isCombatBehaviour() -> bool:
	return false
