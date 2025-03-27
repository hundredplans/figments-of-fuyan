extends IObjectGD

var active_start_tile_public_id: int
var last_active_start_tile_public_id: int
var start_tile_public_ids: Array
var end_tile_public_ids: Array

var LastActiveStartTile: TileGD # Last visible
var ActiveStartTile: TileGD
var start_tiles: Array
var end_tiles: Array
var holders_nodes: Array
var used_this_turn_cards: Array
var ai_cooldown_cards: Dictionary # 3 turn cooldown

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
	ability_save['last_active_start_tile_public_id'] = LastActiveStartTile.public_id if LastActiveStartTile != null else 0
	
	var ai_cooldown_public_ids: Dictionary = {}
	for Card in ai_cooldown_cards:
		ai_cooldown_public_ids[Card.public_id] = ai_cooldown_cards[Card]
	
	ability_save['ai_cooldown_cards'] = ai_cooldown_public_ids
	return super()
	
func onLoadDataLevel() -> void:
	super()
	if active_start_tile_public_id != 0:
		start_tiles = start_tile_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
		end_tiles = end_tile_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
		ActiveStartTile = Game.onFindPublicIDObject(active_start_tile_public_id)
		LastActiveStartTile = Game.onFindPublicIDObject(last_active_start_tile_public_id)
	
	var ai_cooldown_public_ids: Dictionary = ai_cooldown_cards.duplicate()
	ai_cooldown_cards = {}
	for ai_public_id in ai_cooldown_public_ids:
		ai_cooldown_cards[Game.onFindPublicIDObject(ai_public_id)] = ai_cooldown_public_ids[ai_public_id]
		
	used_this_turn_cards = used_this_turn_cards.map(func(x: int): return Game.onFindPublicIDObject(x))
	setHolderVisible()
	
# Sets active start, start tiles and end tiles
func onLoadDataLevelFofInit() -> void:
	super()
	var Tile: TileGD = getTile()
	if isEqual():
		var offset_coords: Array = []
		if isShort(): # Equal Short
			offset_coords = [Vector4i(1, 0, -1, 0), Vector4i(4, 0, -4, 0)]
		else: # Equal Long
			offset_coords = [Vector4i(1, 0, -1, 0), Vector4i(5, 0, -5, 0)]
		
		start_tiles = offset_coords.map(func(x: Vector4i): return Game.getTile(getTile().getCoords() + Game.onRotateCoordsCC(tile_rotation, x)))
		end_tiles = []
		
		for i in range(start_tiles.size() - 1, -1, -1):
			end_tiles.append(start_tiles[i])
		
		ActiveStartTile = start_tiles[0]
	else:
		var offset_coords: Vector4i
		if isShort(): offset_coords = Vector4i(4, 0, -4, 4)
		else: offset_coords = Vector4i(5, 0, -5, 4)
			
		ActiveStartTile = Game.getTile(getTile().getCoords() + Game.onRotateCoordsCC(tile_rotation, offset_coords))
		start_tiles = [ActiveStartTile]
		end_tiles = [Game.getTile(Tile.getCoords() + Game.onRotateCoordsCC(tile_rotation, Vector4i(1, 0, -1, 0)))]
	LastActiveStartTile = ActiveStartTile
	setHolderVisible()

func onLoadModel() -> void:
	super()
	holders_nodes = Helper.getNodeTypeRecursive(Model, MeshInstance3D)\
		.filter(func(x: MeshInstance3D): return x.name.begins_with("Holder"))
	holders_nodes.sort_custom(func(x: MeshInstance3D, y: MeshInstance3D): return str(x.name) > str(y.name))
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
	if !Card.isLevelVisible():
		onForceAction(CameraChangeAction.new(self))
	
var HolderCard: CardGD
var HolderNode: MeshInstance3D
func onActiveEffect(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	onPushAction(OccupyAction.new(Card, end_tiles[start_tiles.find(ActiveStartTile)]))
	used_this_turn_cards.append(Card)
	
	if Card.isEnemy(0): ai_cooldown_cards[Card] = TURN_COOLDOWN_FOR_ABILITY_AND_TRANSFORM 
	
	HolderNode = holders_nodes[start_tiles.find(ActiveStartTile)]
	HolderCard = Card
	
	if !isLevelVisible(): return
	Card.onPauseAnimation()
	onAbility()
	
func onZiplineFinished() -> void:
	HolderNode = null
	HolderCard.onPauseAnimation(false)
	HolderCard = null
	AniPlayer.stop()
	AniPlayer.seek(0, true)
	
	ActiveStartTile = start_tiles[end_tiles.find(ActiveStartTile)]
	if isLevelVisible():
		LastActiveStartTile = ActiveStartTile
	
	setHolderVisible()
	
func setHolderVisible() -> void:
	if LastActiveStartTile == null: return
	for i in range(holders_nodes.size()):
		holders_nodes[i].visible = (start_tiles.find(LastActiveStartTile) == i)
#endregion

#region Advance Turn
func onCardTurnPassed(Card: CardGD) -> void:
	for _Card in used_this_turn_cards:
		if Card == _Card: used_this_turn_cards.erase(Card); break
		
	if Card in ai_cooldown_cards.keys():
		ai_cooldown_cards[Card] -= 1
		if ai_cooldown_cards[Card] == 0:
			ai_cooldown_cards.erase(Card)
		
#endregion

#region Following Holder
func _process(_delta: float) -> void:
	if HolderNode == null: return
	HolderCard.position = HolderNode.global_position - Vector3(0, HolderCard.getTopFromInfo() + 0.4, 0)
#endregion

#region Action
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ActiveEffectUsedAction and action.ActiveEffect in active_effects:
			onZiplineFinished()
#endregion

#region Animation
func onAbility() -> void:
	if isLevelVisible():
		if start_tiles.size() == 1:
			AniPlayer.play("Ability")
		else:
			AniPlayer.play("AbilityLeft" if start_tiles.find(ActiveStartTile) == 0 else "AbilityRight")
#endregion

const POSITIVE_TRANSFORM_VALUE: float = 0.2
const NEGATIVE_TRANSFORM_VALUE: float = -0.5
const TURN_COOLDOWN_FOR_ABILITY_AND_TRANSFORM: int = 3
const CHANCE_TO_USE_REGULAR: float = 0.75
const CHANCE_TO_USE_IN_COOLDOWN: float = 0.05

func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, DFL: DefaultFightLogic) -> TileGD:
	var roll: bool = Random.rollFloat(CHANCE_TO_USE_REGULAR\
	if DFL.Card not in ai_cooldown_cards.keys() else CHANCE_TO_USE_IN_COOLDOWN)
	
	return active_effect_tiles.pickable_tiles[0] if roll else null
	
# 0.2 by default, after u use it -0.5 to step on the tile
func onIObjectSpecificTransforms(tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	for Tile in tiles_to_value:
		if Tile == ActiveStartTile:
			if DFL.Card in ai_cooldown_cards.keys(): tiles_to_value[Tile] += NEGATIVE_TRANSFORM_VALUE
			else: tiles_to_value[Tile] += POSITIVE_TRANSFORM_VALUE
			return
			
func setLevelVisible(state: bool) -> void:
	if state and state != isLevelVisible():
		LastActiveStartTile = ActiveStartTile
		setHolderVisible()
	super(state)
	
