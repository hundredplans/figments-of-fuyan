extends CardGD

const HELPFUL_HELMET_FIELD_EFFECT_ID: int = 5
const MINIMUM_HEALTH_TO_USE_HELPFUL_HELMET_AI: int = 3

const TIER_ONE_MAX_HP: int = 1
const TIER_TWO_MAX_HP: int = 1
const TIER_THREE_MAX_HP: int = 1
const TIER_FOUR_MAX_HP: int = 2

const MINIMUM_TIER_GAIN_HP: int = 2

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Helpful Helmet":
		var tiles: Array = Game.getAdjacentTiles(Tile)
		return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getAllyFieldCard(x, team)))
	return null
	
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
		
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Helpful Helmet":
		var Card: CardGD = Game.getFieldCard(PickedTile)
		var field_effect_data := SavedDataFieldEffect.new(HELPFUL_HELMET_FIELD_EFFECT_ID, true)
		field_effect_data.display_number = getTierMaxHp()
		var FieldEffect: FieldEffectGD = SavedData.onLoadModel(field_effect_data, Card)
		FieldEffect.Card = Card
		
		var actions: Array = [DestroyAction.new(self, self), AddFieldEffectAction.new(FieldEffect)]
		
		if tier >= MINIMUM_TIER_GAIN_HP:
			actions.append(StatAction.new(StatInfo.new(Card, Game.Stats.MAX_HEALTH, getTierMaxHp())))
		
		onForceAction(AnimationModifierAction.new(self, "Death", "Ability"))
		onPushAction(actions)
		
# Use if a unit is adjacent with 3 or more health, if there's no units on board with 3 or more health use on whoever
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	if !isLevelVisible(): return null
	var card_to_health: Dictionary = {}
	for PickableTile: TileGD in active_effect_tiles.pickable_tiles:
		var Card: CardGD = Game.getFieldCard(PickableTile)
		card_to_health[Card] = Card.health
		
	var max_ally_health_on_field: int = Game.getAllyUnits(team)\
		.filter(func(x: CardGD): return x != self)\
		.map(func(x: CardGD): return x.health).max()
		
	var adjacent_max_health: int = card_to_health.values().max()
	if adjacent_max_health >= MINIMUM_HEALTH_TO_USE_HELPFUL_HELMET_AI or max_ally_health_on_field < MINIMUM_HEALTH_TO_USE_HELPFUL_HELMET_AI:
		var cards: Array = card_to_health.keys()
		cards.shuffle()
		
		for Card in cards:
			if card_to_health[Card] == adjacent_max_health:
				return Card.getTile()
	return null
	
const BONUS_PER_ADJACENT_ALLY_ON_TILE: float = 0.25
# +0.25 per unit Palmita is adjacent to on a tile
func onUnitSpecificTransforms(tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	for TransformTile: TileGD in tiles_to_value:
		var adjacency_bonus: float = DFL.getAllies().filter(func(x: CardGD): return Game.isAdjacent(x.getTile(), TransformTile)).size() * BONUS_PER_ADJACENT_ALLY_ON_TILE
		tiles_to_value[TransformTile] += adjacency_bonus

func getTierMaxHp() -> int:
	match tier:
		1: return TIER_ONE_MAX_HP
		2: return TIER_TWO_MAX_HP
		3: return TIER_THREE_MAX_HP
		4: return TIER_FOUR_MAX_HP
	return 0
