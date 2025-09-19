extends IObjectGD
const WISHING_WELL_ODDS: float = 0.1
const WISHING_WELL_DELAY: float = 1.5

func onProcessAction(action: Action) -> void:
	super(action)
	
func isValidActiveEffect(Card: CardGD) -> bool: # Returns the ability effects the Card can view
	return super(Card) and isAdjacent(Card.getCoords())
	
func isActiveEffectDisabled(_Card: CardGD) -> bool:
	return super(_Card) or Game.getSaveFile().getShillings() <= 0
	
func getActiveEffectTiles(_Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new([getTile()], [getTile()])
	
func onActiveEffect(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	var roll: bool = Random.rollFloat(WISHING_WELL_ODDS)
	var actions: Array = [DelayAction.new(WISHING_WELL_DELAY),
		CameraChangeAction.new(Card), ChangeShillingsAction.new(-1)]
	if roll: actions.append(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, 1)))
	onPushAction(actions)
	
func onActiveEffectPre(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	onForceAction(CameraChangeAction.new(self))
	onForceAction(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.getTile(), getTile())))

func onAIAbilityChecker(_active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return null
