extends CardGD

const TIER_ONE_ATTACK: int = 1
const TIER_TWO_ATTACK: int = 2
const TIER_THREE_ATTACK: int = 2
const TIER_FOUR_ATTACK: int = 2

const TIER_ONE_HEAL: int = 1
const TIER_TWO_HEAL: int = 1
const TIER_THREE_HEAL: int = 1
const TIER_FOUR_HEAL: int = 2

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Treeleaf Remedy":
		var tiles: Array = Game.getAdjacentOrCloserTiles(Tile, 2)
		return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getAllyFieldCard(x, team) != null))
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Treeleaf Remedy":
		var Card: CardGD = Game.getFieldCard(PickedTile)
		var attack_gain: int = getTierAttack()
		var heal_amount: int = getTierHeal()
		var actions: Array = [
			StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, attack_gain, 1)),
			DelayedHealAction.new(HealDatastore.new(Card, getTierHeal(), 1)),
			ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, Card.Tile))]
		
		onPushAction(actions)
		onAbility()
		
# If the unit is in combat, is healable, then sorted by how low the attack is
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
	
	cards = cards.filter(func(x: CardGD): return x.isHealable() and x.isInCombat())
	cards.shuffle()
	cards.sort_custom(func(x: CardGD, y: CardGD): return x.attack > y.attack)
	
	if cards.is_empty(): return null
	return cards[0].getTile()
	
func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Treeleaf Remedy")
	if !use_default_values and active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super(true)

func getTierAttack() -> int:
	match tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
	
func getTierHeal() -> int:
	match tier:
		1: return TIER_ONE_HEAL
		2: return TIER_TWO_HEAL
		3: return TIER_THREE_HEAL
		4: return TIER_FOUR_HEAL
	return 0
