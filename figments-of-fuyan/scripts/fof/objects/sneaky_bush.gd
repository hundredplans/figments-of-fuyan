extends IObjectGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func getValidActiveEffects(Card: CardGD) -> Array: # Returns the ability effects the Card can view
	return []
	
func getActiveEffectTiles(_active_effect: ActiveEffectDatastore, _Card: CardGD) -> ActiveEffectTiles:
	return null
	
func onActiveEffect(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, _Card: CardGD) -> void:
	pass
	
# Triggers before ActiveEffectUsedAction, for VFX
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, _Card: CardGD) -> void: 
	pass

func onSave() -> SavedDataIObject:
	return super()

func onLoadDataLevel() -> void:
	super()
	# Vision things when first loaded
