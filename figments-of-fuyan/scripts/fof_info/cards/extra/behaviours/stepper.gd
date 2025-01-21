class_name Stepper extends Behaviour

func getCombatTiles(_Card: CardGD, tiles: Array, enemies: Array, _allies: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	for Tile in tiles:
		tiles_to_value[Tile] = getValueFromInAttackableRange(Tile, enemies)
	return tiles_to_value

func getValueFromInAttackableRange(Tile: TileGD, enemies: Array) -> float:
	for Card in enemies:
		var attack_range: int = Card.getAttackRange()
		if Game.getCoordsDistance(Tile.getCoords(), Card.getCoords()) + attack_range <= 0:
			return 0.0
	return 1.0

func isOutOfCombatBehaviour() -> bool:
	return false

func isCombatBehaviour() -> bool:
	return true
