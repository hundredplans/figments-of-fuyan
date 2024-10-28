extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == info.name:
		var pickable_tiles: Array = ([Card.Tile] if info.id != 1 or Card.isHealable() else [])
		return ActiveEffectTiles.new([Card.Tile], pickable_tiles)
	return null

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == info.name:
		var type: Game.Stats
		var turns: int = 1
		
		match info.id:
			1: type = Game.Stats.HEALTH; turns = 0
			4: type = Game.Stats.ATTACK
			6: type = Game.Stats.SPEED
		
		onPushAction(StatAction.new(StatInfo.new(Card, type, 1, turns)))
		
func onToolEquipped() -> void:
	var type: Game.Stats
	match info.id:
		1: type = Game.Stats.MAX_HEALTH
		4: type = Game.Stats.ATTACK
		6: type = Game.Stats.MAX_SPEED
		
	onPushAction(StatAction.new(StatInfo.new(Card, type, 1)))
	
func onToolUnequipped() -> void:
	super()
	var type: Game.Stats
	match info.id:
		1: type = Game.Stats.MAX_HEALTH
		4: type = Game.Stats.ATTACK
		6: type = Game.Stats.MAX_SPEED
		
	onPushAction(StatAction.new(StatInfo.new(Card, type, -1)))
