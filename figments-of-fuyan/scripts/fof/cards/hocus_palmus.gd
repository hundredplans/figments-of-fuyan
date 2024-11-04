extends CardGD

#func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	#super(active_effect)
	#if active_effect is ActiveAbilityDatastore and active_effect.name == "Cocus Pocus":
		#var tiles: Array = Game.getAllyUnits(0)
		#return ActiveEffectTiles.new(tiles, tiles.filter(onPickable))
	#return null
	#
#func onPickable(_PickableTile: TileGD) -> bool:
	#var Card: CardGD = Game.getAllyFieldCard(Tile, team)
	#return Card != null and ((Card == self and !ascended) or (Card.isHealable() and ascended))
	#
#func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	#super(active_effect, PickedTile, active_effect_tiles)
	#if active_effect is ActiveAbilityDatastore and active_effect.name == "Cocus Pocus":
		#if !ascended:
			#var Card: CardGD = 
			#var actions: Array = []
			#
			#onPushAction(actions)
			#onAbility()
