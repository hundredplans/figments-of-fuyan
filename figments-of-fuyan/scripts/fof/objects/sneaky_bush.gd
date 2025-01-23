extends IObjectGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is OccupyAction and action.Tile in occupied_tiles:
			onPushAction(IObjectActivatedAction.new(self, action))
	
func onIObject(action: Action) -> void:
	action.Card.onCreateBaseStatusEffect(2, -1)
	
func getValidActiveEffects(Card: CardGD) -> Array: # Returns the ability effects the Card can view
	return active_effects if Card.Tile in occupied_tiles else []
	
func getActiveEffectTiles(_active_effect: ActiveEffectDatastore, _Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new(occupied_tiles, occupied_tiles)
	
func onActiveEffect(active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, _Card: CardGD) -> void:
	if active_effect.name == "Stomp":
		onPushAction(ClearTileObjectAction.new(self))
	
# Triggers before ActiveEffectUsedAction, for VFX
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, _Card: CardGD) -> void: 
	pass

func onSave() -> SavedDataIObject:
	return super()

func onLoadDataLevel() -> void:
	super()
	# Vision things when first loaded
	
const CHANCE_TO_DESTROY: float = 0.5
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles[0] if Random.rollFloat(CHANCE_TO_DESTROY) else null
