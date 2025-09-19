extends IObjectGD

const COCONUT_ID: int = 13
const COCONUT_DROP_ODDS: float = 0.25
const ACTION_DELAY: float = 1
const RECHARGE_MIN_TURN: int = 4
const RECHAGRE_MAX_TURN: int = 8
var recharge: int
	
func onAdvanceTurn(team: int) -> void:
	super(team)
	if team == 0:
		recharge = max(recharge - 1, 0)
		
func isValidActiveEffect(Card: CardGD) -> bool:
	return super(Card) and recharge == 0 and Card.isAdjacent(occupied_tiles[0].getCoords())
	
func isActiveEffectDisabled(Card: CardGD) -> bool:
	return super(Card) or Card.getAttacks() == 0
	
func getActiveEffectTiles(_Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new([getTile()], [getTile()])
	
func onActiveEffect(PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD = null) -> void:
	var animation_action := AnimationAction.new(Card, "Attack")
	animation_action.setActionDelay(Game.ATTACK_DELAY)
	var actions: Array = [ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.getTile(), PickedTile)),
		animation_action, ChangeAttacksAction.new(Card, Card.getAttacks() - 1)]
		
	var coconut_tiles: Array = []
	var tiles: Array = Game.getAdjacentTiles(occupied_tiles[0])
	for Tile in tiles.filter(func(x: TileGD): return !x.occupied_objects.any(func(y: ObjectGD): return y.info.id == COCONUT_ID) and !x.isSolid()):
		if !Random.rollFloat(COCONUT_DROP_ODDS): continue
		coconut_tiles.append(Tile)
		
	var damage_actions: Array = []
	for Tile: TileGD in coconut_tiles:
		var TileCard: CardGD = Game.getFieldCard(Tile)
		if TileCard == null:
			actions.append(CreateObjectAction.new(COCONUT_ID, Tile))
		else: damage_actions.append(DamageAction.new(self, TileCard, 1))
		
	actions += damage_actions
	recharge = range(RECHARGE_MIN_TURN, RECHAGRE_MAX_TURN + 1).pick_random()
	onPushAction(actions)
	
func onSave() -> SavedDataIObject:
	ability_save['recharge'] = recharge
	return super()

const NEGATIVE_TRANSFORM: float = -10
const POSITIVE_TRANSFORM: float = 0.5
# If recharging, the unit is one health or if the unit is not in combat give a -10, otherwise +0.5
func onIObjectSpecificTransforms(tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	if !tiles_to_value.has(occupied_tiles[0]): return
	tiles_to_value[occupied_tiles[0]] += NEGATIVE_TRANSFORM if (recharge > 0 or DFL.Card.health == 1 or !DFL.Card.isInCombat()) else POSITIVE_TRANSFORM
	
func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return active_effect_tiles.pickable_tiles[0]
