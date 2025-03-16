class_name Patroller extends Behaviour

func getOutOfCombatTiles(_Card: CardGD, tiles: Array, _allies: Array, _enemies: Array) -> Dictionary:
	var tiles_by_value: Dictionary = {}
	for Tile: TileGD in tiles:
		var turns_unseen: int = clamp(Tile.getTurnsUnseen(), 0, 10)
		var value: float = 0.0 if turns_unseen < 5 else (turns_unseen / 10.0)
		tiles_by_value[Tile] = value
	return tiles_by_value

func isOutOfCombatBehaviour() -> bool:
	return true

func isCombatBehaviour() -> bool:
	return false
