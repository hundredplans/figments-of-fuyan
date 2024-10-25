extends CardGD

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	if active_effect.name == "Palmsale":
		var tiles: Array = Game.getAdjacentTiles(Tile)
		var pickable_tiles: Array = tiles.filter(isPickable)
		return ActiveEffectTiles.new(tiles, pickable_tiles)
	return null
	
func isPickable(_Tile: TileGD) -> bool:
	var Card: CardGD = Game.getAllyFieldCard(_Tile, team)
	return Card != null and Card.isHealable()
		
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD) -> void:
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Palmsale":
		active_effect.charges -= 1
		active_effect.used = true
		
		var actions: Array = [StatAction.new(Game.getFieldCard(PickedTile), Game.Stats.HEALTH, 1),\
		ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile))]
		
		onPushAction(actions)
		onAbility()
	
func getDescription() -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Palmsale")
	if active_effect != null:
		var number: String = "[1]" if !ascended else "[2]"
		return Helper.getDescriptionNumeric(super(), [str(active_effect.charges)], [["ABILITY ", number]])
	return super()
