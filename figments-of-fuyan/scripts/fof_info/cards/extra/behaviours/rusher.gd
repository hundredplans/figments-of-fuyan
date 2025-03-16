class_name Rusher extends Behaviour

func getCombatTiles(Card: CardGD, tiles: Array, enemies: Array, _allies: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	var attack_range: int = Card.getAttackRange()
	for Tile in tiles:
		var distance: float = max(enemies.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), Tile.getCoords()) - attack_range).min(), 1)
		distance = max(distance, 1)
		tiles_to_value[Tile] = 1.0 / distance
	return tiles_to_value

func isOutOfCombatBehaviour() -> bool:
	return false

func isCombatBehaviour() -> bool:
	return true
