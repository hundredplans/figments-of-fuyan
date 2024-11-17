extends IObjectGD

var active_start_tile_public_id: int
var start_tile_public_ids: Array
var end_tile_public_ids: Array

var ActiveStartTile: TileGD
var start_tiles: Array
var end_tiles: Array
var holders_name: Array = ["HolderRight", "HolderLeft"]

var used_this_turn_cards: Array

#region Helper
func isEqual() -> bool:
	return variation in [0, 1]
	
func isShort() -> bool:
	return variation in [0, 2]
#endregion

#region Save / Load
func onSave() -> SavedDataIObject:
	ability_save['start_tile_public_ids'] = start_tiles.map(func(x: TileGD): return x.public_id)
	ability_save['end_tile_public_ids'] = end_tiles.map(func(x: TileGD): return x.public_id)
	ability_save['active_start_tile_public_id'] = ActiveStartTile.public_id if ActiveStartTile != null else 0
	ability_save['used_this_turn_cards'] = used_this_turn_cards.map(func(x: CardGD): return x.public_id)
	return super()
		
func onLoadDataLevel() -> void:
	super()
	if active_start_tile_public_id != 0:
		start_tiles = start_tile_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
		end_tiles = end_tile_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
		ActiveStartTile = Game.onFindPublicIDObject(active_start_tile_public_id)
		
	used_this_turn_cards = used_this_turn_cards.map(func(x: int): return Game.onFindPublicIDObject(x))
		
# Sets active start, start tiles and end tiles
func onLoadDataLevelFofInit() -> void:
	super()
	var Tile: TileGD = getTile()
	if isEqual():
		var offset_coords: Array = []
		if isShort(): # Equal Short
			offset_coords = [Vector4i(1, 0, -1, 0), Vector4i(4, 0, -4, 0)]
			start_tiles = []
		else: # Equal Long
			pass
	else:
		var offset_coords: Vector4i
		if isShort(): offset_coords = Vector4i(4, 0, -4, 4)
		else: offset_coords = Vector4i(5, 0, -5, 4)
			
		ActiveStartTile = Game.getTile(getTile().getCoords() + Game.onRotateCoordsCC(tile_rotation, offset_coords))
		start_tiles = [ActiveStartTile]
		end_tiles = [Game.getTile(Tile.getCoords() + Game.onRotateCoordsCC(tile_rotation, Vector4i(1, 0, -1, 0)))]
#endregion

#region Active Effects
func getValidActiveEffects(Card: CardGD) -> Array:
	return active_effects if Card.Tile == ActiveStartTile else []
		
func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore, Card: CardGD) -> bool:
	var Tile: TileGD = end_tiles[start_tiles.find(ActiveStartTile)]
	return Tile.isSolid() or Game.getFieldCard(Tile) != null or Card in used_this_turn_cards
	
func getActiveEffectTiles(_active_effect: ActiveEffectDatastore, _Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new([ActiveStartTile], [ActiveStartTile])
	
func onActiveEffectPre(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	super(active_effect, PickedTile, active_effect_tiles, Card)
	onForceAction(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.Tile, end_tiles[start_tiles.find(ActiveStartTile)])))
	
var HolderCard: CardGD
var HolderNode: MeshInstance3D
func onActiveEffect(active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	onPushAction(OccupyAction.new(Card, end_tiles[start_tiles.find(ActiveStartTile)]))
	used_this_turn_cards.append(Card)
	
	if !getLevelVisible(): return
	onAbility()
	HolderNode = Helper.getNodeTypeRecursive(self, MeshInstance3D)\
		.filter(func(x: MeshInstance3D): return x.name == holders_name[start_tiles.find(ActiveStartTile)])[0]
	HolderCard = Card
	
func onZiplineFinished() -> void:
	HolderNode = null
	HolderCard = null
	AniPlayer.stop()
	AniPlayer.seek(0, true)
#endregion

#region Advance Turn
func onAdvanceTurn(team: int) -> void:
	super(team)
	for Card in used_this_turn_cards.filter(func(x: CardGD): return x.team == team):
		used_this_turn_cards.erase(Card)
#endregion

#region Following Holder
func _process(_delta: float) -> void:
	if HolderNode == null: return
	HolderCard.position = HolderNode.global_position - Vector3(0, HolderCard.info.top + 0.4, 0)
#endregion

#region Action
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ActiveEffectUsedAction and action.ActiveEffect in active_effects:
			onZiplineFinished()
#endregion
