extends CardGD

const ABILITY_DELAY: float = 3.0
const CHARMING_STANCE_FIELD_EFFECT_ID: int = 3
const GUARANTEED_CHARMING_STANCE_UNIT_AMOUNT_AI: int = 2
const SINGLE_UNIT_CHANCE: float = 0.1

const TIER_ONE_HEAL: int = 1
const TIER_TWO_HEAL: int = 2
const TIER_THREE_HEAL: int = 2
const TIER_FOUR_HEAL: int = 2

const TIER_ONE_ATTACK: int = 1
const TIER_TWO_ATTACK: int = 1
const TIER_THREE_ATTACK: int = 2
const TIER_FOUR_ATTACK: int = 2

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Charming Stance":
		var tiles: Array = getVisibleTiles()
		tiles.erase(Tile)
		return ActiveEffectTiles.new(tiles, tiles.filter(onPickable))
	return null
	
func onActiveEffectPre(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Charming Stance":
		onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
	
func onPickable(x: TileGD) -> bool:
	var Card: CardGD = Game.getAllyFieldCard(x, team)
	if Card != null and Card.isHealable():
		return true
	return false
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Charming Stance":
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
		var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getAllyFieldCard(x, team))\
			.filter(func(x: CardGD): return x.isHealable())
			
		var attack_amount: int = getTierAttack() * cards.size()
		var heal_amount: int = getTierHeal()
		var actions: Array = [animation_action,
			HealAction.new(cards.map(func(x: CardGD): return HealDatastore.new(x, getTierHeal()))),
			StatAction.new(StatInfo.new(self, Game.Stats.ATTACK, attack_amount))]
		
		onPushAction(actions)
		
# Guaranteed for 2 units, 10% chance to use for 1 unit
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	if active_effect_tiles.pickable_tiles.size() >= GUARANTEED_CHARMING_STANCE_UNIT_AMOUNT_AI:
		return active_effect_tiles.pickable_tiles.pick_random()
	elif active_effect_tiles.pickable_tiles.size() == 1 and Random.rollFloat(SINGLE_UNIT_CHANCE):
		return active_effect_tiles.pickable_tiles.pick_random()
	return null

func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Charming Stance")
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
