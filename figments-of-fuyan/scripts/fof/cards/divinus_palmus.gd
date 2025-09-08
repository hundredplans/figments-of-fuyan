extends CardGD

# +1 Ability charge on update

# ABILITY [2]: Heal [1] HP to an ally or self
# Remove interlinks for paths

const ABILITY_DELAY: float = 2.4
const SHOP_PRICE_MULT: float = 1.1
var holy_travelled_amount: int

func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Coconut Touch":
		var tiles: Array = getVisibleTiles()
		return ActiveEffectTiles.new(tiles, tiles.filter(isPickable))
	return null

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Coconut Touch":
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
		var actions: Array = [
			animation_action,
			HealAction.new(HealDatastore.new(Game.getFieldCard(PickedTile), 1))]
		
		if Tile != PickedTile:
			onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
		
		onPushAction(actions)
		
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()
		
func isPickable(_Tile: TileGD) -> bool:
	var Card: CardGD = Game.getAllyFieldCard(_Tile, team)
	return Card != null and Card.isHealable()

func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Coconut Touch")
	if !use_default_values and active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super(true)

func onSave() -> SavedDataCard:
	ability_save['holy_travelled_amount'] = holy_travelled_amount
	return super()
