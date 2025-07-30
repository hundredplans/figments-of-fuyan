extends CardGD

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "INSERT NAME":
		var tiles: Array = []
		return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return x))
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "INSERT NAME":
		var actions: Array = []
		
		onPushAction(actions)
		onAbility()
