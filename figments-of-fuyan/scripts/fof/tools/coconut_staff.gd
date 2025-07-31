extends ToolGD
	
const MINIMUM_TIER_FOR_GLOBAL_HEAL: int = 3
const MINIIMUM_FOR_AI_TO_USE: int = 2

const TIER_ONE_HEAL: int = 1
const TIER_TWO_HEAL: int = 2
const TIER_THREE_HEAL: int = 2
const TIER_FOUR_HEAL: int = 3
	
func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == info.name:
		return ActiveEffectTiles.new([Card.getTile()], [Card.getTile()])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == info.name:
		var healable_allies: Array = getHealableAllies()
		var heal_amount: int = getHealFromTier()
		var actions: Array = [HealAction.new(healable_allies.map(func(x: CardGD): return HealDatastore.new(x, heal_amount)))]
		onPushAction(actions)
	
# When possible
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	var healable_allies: Array = getHealableAllies()
	return active_effect_tiles.pickable_tiles[0] if healable_allies.size() >= MINIIMUM_FOR_AI_TO_USE else null

func getHealableAllies() -> Array:
	var healable_allies: Array = Card.getVisibleFieldCardsAllies()\
		if tier <= MINIMUM_TIER_FOR_GLOBAL_HEAL else Game.getAllyUnits(Card.team)
	healable_allies.erase(self)
	healable_allies = healable_allies.filter(func(x: CardGD): return x.isHealable())
	return healable_allies
	
func getHealFromTier() -> int:
	match tier:
		1: return TIER_ONE_HEAL
		2: return TIER_TWO_HEAL
		3: return TIER_THREE_HEAL
		4: return TIER_FOUR_HEAL
	push_warning("Invalid tier not in [1-4]")
	return 0

func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Coconut Staff")
	if !use_default_values and active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super(true)
