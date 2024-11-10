extends IObjectGD

var active_start_tile_public_id: int
var start_tile_public_ids: Array
var end_tile_public_ids: Array

var ActiveStartTile: TileGD
var start_tiles: Array
var end_tiles: Array

func getValidActiveEffects(Card: CardGD) -> Array:
	return active_effects if Card.Tile == ActiveStartTile else []
		
func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore, _Card: CardGD) -> bool:
	var Tile: TileGD = end_tiles[start_tiles.find(ActiveStartTile)]
	return !Tile.isSolid() and Game.getFieldCard(Tile) == null
		
func onSave() -> SavedDataIObject:
	ability_save['start_tile_public_ids'] = start_tiles.map(func(x: TileGD): return x.public_id)
	ability_save['end_tile_public_ids'] = end_tiles.map(func(x: TileGD): return x.public_id)
	ability_save['active_start_tile_public_id'] = ActiveStartTile.public_id if ActiveStartTile != null else 0
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	
	if active_start_tile_public_id != 0:
		ActiveStartTile = Game.onFindPublicIDObject(active_start_tile_public_id)
		
# Sets active start, start tiles and end tiles
func onFofInit() -> void:
	super()
	print(variation)
	if isEqual():
		if isShort(): # Equal Short
			pass
		else: # Equal Long
			pass
	else:
		if isShort(): # High Short
			pass
		else: # High Long
			ActiveStartTile = Game.getTile(getTile().getCoords() + Game.onRotateCoords(Vector4i(5, 0, -5, -4), tile_rotation))
			start_tiles = [ActiveStartTile]
			end_tiles = [Game.getTile(getTile().getCoords() + Game.onRotateCoords(Vector4i(1, 0, -1, 0), tile_rotation))]
			ActiveStartTile.visible = false
			for end in end_tiles: end.visible = false
		
func isEqual() -> bool:
	return variation in [0, 1]
	
func isShort() -> bool:
	return variation in [0, 3]
