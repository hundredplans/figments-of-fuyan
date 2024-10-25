extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name.ends_with("Pendant"):
		var pickable_tiles: Array = ([Card.Tile] if info.id != 1 or Card.isHealable() else [])
		return ActiveEffectTiles.new([Card.Tile], pickable_tiles)
	return null

func onActiveEffect(active_effect: ActiveEffectDatastore, _PickedTile: TileGD) -> void:
	if active_effect.name.ends_with("Pendant"):
		var type: Game.Stats
		var turns: int = 1
		
		match info.id:
			1: type = Game.Stats.HEALTH; turns = 0
			4: type = Game.Stats.ATTACK
			6: type = Game.Stats.SPEED
		
		active_effect.charges -= 1
		active_effect.used = true
		onPushAction(StatAction.new(Card, type, 1, turns))
		
func onToolEquipped() -> void:
	var type: Game.Stats
	match info.id:
		1: type = Game.Stats.MAX_HEALTH
		4: type = Game.Stats.ATTACK
		6: type = Game.Stats.MAX_SPEED
		
	onPushAction(StatAction.new(Card, type, 1))
	
func onToolUnequipped() -> void:
	super()
	var type: Game.Stats
	match info.id:
		1: type = Game.Stats.MAX_HEALTH
		4: type = Game.Stats.ATTACK
		6: type = Game.Stats.MAX_SPEED
		
	onPushAction(StatAction.new(Card, type, -1))
