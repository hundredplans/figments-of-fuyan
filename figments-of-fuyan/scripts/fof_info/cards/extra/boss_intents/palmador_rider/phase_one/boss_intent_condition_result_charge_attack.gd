class_name BossIntentConditionResultChargeAttack extends BossIntentConditionResult

var wall_adjacent_tiles: Array
@export var wall_adjacent_tiles_public_ids: Array

var charge_tiles: Array
@export var charge_tiles_public_ids: Array

func onSave() -> void:
	wall_adjacent_tiles_public_ids = wall_adjacent_tiles.map(func(x: TileGD): return x.public_id)
	charge_tiles_public_ids = charge_tiles.map(func(x: TileGD): return x.public_id)
	
func onLoad() -> void:
	wall_adjacent_tiles = wall_adjacent_tiles_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
	charge_tiles = charge_tiles_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
	
func getChargeEndTile() -> TileGD:
	return charge_tiles[charge_tiles.size() - 1] if !charge_tiles.is_empty() else null

func getWallAdjacentTiles() -> Array:
	return wall_adjacent_tiles
	
func getChargeTiles() -> Array:
	return charge_tiles

func setChargeTiles(tiles: Array) -> void:
	charge_tiles = tiles
	
func setWallAdjacentTiles(tiles: Array) -> void:
	wall_adjacent_tiles = tiles
