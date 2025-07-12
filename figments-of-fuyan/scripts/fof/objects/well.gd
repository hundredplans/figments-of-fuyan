extends IObjectGD
const WISHING_WELL_ODDS: float = 0.1

func onProcessAction(action: Action) -> void:
	super(action)
	
func getValidActiveEffects(Card: CardGD) -> Array: # Returns the ability effects the Card can view
	return active_effects if isAdjacent(Card.getCoords()) else []
	
func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore, _Card: CardGD) -> bool:
	return Game.getSaveFile().getShillings() <= 0
	
func getActiveEffectTiles(_active_effect: ActiveEffectDatastore, _Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new([getTile()], [getTile()])
	
func onActiveEffect(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	var roll: bool = Random.rollFloat(WISHING_WELL_ODDS)
	var actions: Array = []
	
	actions.append(CameraChangeAction.new(Card))
	actions.append(ChangeShillingsAction.new(-1))
	if roll: actions.append(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, 1)))
	onPushAction(actions)
	
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	onForceAction(CameraChangeAction.new(self))
	onForceAction(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.getTile(), getTile())))

func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, _active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	return null
