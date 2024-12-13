class_name Unengager extends Behaviour

const DISTANCE_TO_VALUE: Dictionary = {
	1: 0.0,
	2: 0.0,
	3: 0.0,
	4: 1.0,
	5: 0.5
	# > 5 is 0
}
func getCombatTiles(Card: CardGD, tiles: Array, attackables: Array) -> Dictionary:
	var tiles_to_value: Dictionary = {}
	var is_violence_recent: bool = Card.last_seen_violence <= 2
	for Tile in tiles:
		tiles_to_value[Tile] = getValueByAttackersDistance(Tile, attackables) if !is_violence_recent else getValueFromInAttackableRange(Tile, attackables)
	return tiles_to_value

func getValueFromInAttackableRange(Tile: TileGD, attackables: Array) -> float:
	for Card in attackables:
		var attack_range: int = Card.getAttackRange()
		if Game.getCoordsDistance(Tile.getCoords(), Card.getCoords()) + attack_range <= 0:
			return 0.0
	return 1.0

func getValueByAttackersDistance(Tile: TileGD, attackables: Array) -> float:
	var max_distance: int = 0
	for Card in attackables:
		var distance: int = Game.getCoordsDistance(Tile.getCoords(), Card.getCoords())
		if distance > max_distance: max_distance = distance
		if distance < 4: return 0.0
	return DISTANCE_TO_VALUE[max_distance] if max_distance < 6 else 0.0
