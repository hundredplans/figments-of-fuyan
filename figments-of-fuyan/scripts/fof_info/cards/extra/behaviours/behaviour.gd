class_name Behaviour extends Resource

func getCombatTiles(_Card: CardGD, tiles: Array, _attackables: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	for Tile in tiles:
		tiles_to_value[Tile] = 1.0
	return tiles_to_value
	
func getOutOfCombatTiles(_Card: CardGD, tiles: Array, _allies: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	for Tile in tiles:
		tiles_to_value[Tile] = 1.0
	return tiles_to_value
