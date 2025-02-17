extends ToolGD

var healed_allies: Array
func onProcessAction(action: Action) -> void:
	super(action)
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()

func onSave() -> SavedDataTool:
	ability_save['healed_allies'] = healed_allies.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	healed_allies = healed_allies.map(func(id: int): return Game.onFindPublicIDObject(id))
	
func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == info.name:
		var in_range_tiles: Array = Game.getAdjacentTiles(Card.Tile) if !ascended else Card.getVisibleTiles()
		return ActiveEffectTiles.new(in_range_tiles, in_range_tiles.filter(isPickable))
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == info.name:
		var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
		var stat_infos: Array = cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.HEALTH, 1))
		
		onPushAction(StatAction.new(stat_infos))
		healed_allies += cards
		
func isPickable(_Tile: TileGD) -> bool:
	var FieldCard: CardGD = Game.getAllyFieldCard(_Tile, Card.team)
	return FieldCard != null and FieldCard != Card and FieldCard not in healed_allies and FieldCard.isHealable()
	
# When possible
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()
