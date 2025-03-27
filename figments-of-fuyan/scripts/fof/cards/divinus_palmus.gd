extends CardGD

# +1 Ability charge on update

# ABILITY [2]: Heal [1] HP to an ally or self

#Holy path which shows up on map (you can go off it and get a debuff but if you go back on it's good)
#Always has a shop on it and a campfire otherwise random
#Fight -> +1 budget
#Encounter -> More likely to be negative
#Shop -> 10% more expensive

const SHOP_PRICE_MULT: float = 1.1

func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Coconut Touch":
		var tiles: Array = getVisibleTiles()
		return ActiveEffectTiles.new(tiles, tiles.filter(isPickable))
	return null

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Coconut Touch":
		var actions: Array = [
			HealAction.new(HealDatastore.new(Game.getFieldCard(PickedTile), 1))]
		
		if Tile != PickedTile: actions.append(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
		
		onPushAction(actions)
		onAbility()
		
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()
		
func isPickable(_Tile: TileGD) -> bool:
	var Card: CardGD = Game.getAllyFieldCard(_Tile, team)
	return Card != null and Card.isHealable()

func getDescription() -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Coconut Touch")
	if active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return Helper.getDescription(super(), [3 if Game.getChampionLevel() >= 2 else 2])
