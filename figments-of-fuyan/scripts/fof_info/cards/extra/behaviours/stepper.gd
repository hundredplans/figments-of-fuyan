class_name Stepper extends Behaviour

func getCombatTiles(Card: CardGD, tiles: Array, enemies: Array, _allies: Array) -> Dictionary:
	return onStayOutOfAttackRange(tiles, enemies) if !isValidFirstHit(Card, tiles, enemies) else onGetFirstHit(Card, tiles, enemies)
	
func onStayOutOfAttackRange(tiles: Array, enemies: Array) -> Dictionary:
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
	
func onGetFirstHit(Card: CardGD, tiles: Array, enemies: Array) -> Dictionary: # 1 on tiles enemies are on, 0.75 on tiles that are attack range away, 0 elsewhere
	var tiles_to_value: Dictionary = {}
	var attack_range: int = Card.getAttackRange()
	var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
	
	for Tile: TileGD in tiles:
		if Tile in enemy_tiles: tiles_to_value[Tile] = 1.0
		elif enemy_tiles.any(func(x: TileGD): return Game.getCoordsDistance(Tile.getCoords(), x.getCoords()) == attack_range): tiles_to_value[Tile] = 0.75
		else: tiles_to_value[Tile] = 0.0
	
	return tiles_to_value
	
func isValidFirstHit(Card: CardGD, tiles: Array, enemies: Array) -> bool:
	var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
	return false if tiles.is_empty() else tiles.any(func(x: TileGD): return x in enemy_tiles)

func getMinAttackDistanceFromInAttackableRange(Tile: TileGD, enemies: Array) -> float:
	return enemies.map(func(x: CardGD): return max(Game.getCoordsDistance(Tile.getCoords(), x.getCoords()) - (x.speed + x.getAttackRange()), 0)).min()

func isOutOfCombatBehaviour() -> bool:
	return false

func isCombatBehaviour() -> bool:
	return true
