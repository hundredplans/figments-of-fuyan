extends CardGD

const CHARMING_STANCE_FIELD_EFFECT_ID: int = 3
const GUARANTEED_CHARMING_STANCE_UNIT_AMOUNT_AI: int = 2
const SINGLE_UNIT_CHANCE: float = 0.1

var valid_cards: Array = []
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidTrauma(action) and action.Defender in valid_cards:
		onPushAction(TraumaAction.new(self, action))

func onTrauma(_death_action: DeathAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH], [1, 1])))

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Charming Stance":
		var tiles: Array = getVisibleTiles()
		tiles.erase(Tile)
		return ActiveEffectTiles.new(tiles, tiles.filter(onPickable))
	return null
	
func onActiveEffectPre(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Charming Stance":
		onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
	
func onPickable(x: TileGD) -> bool:
	var Card: CardGD = Game.getAllyFieldCard(x, team)
	if Card != null and Card.isHealable():
		return true
	return false
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Charming Stance":
		var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getAllyFieldCard(x, team))
		var actions: Array = [HealAction.new(cards, 1)]
		
		for Card: CardGD in cards.filter(func(x: CardGD): return x not in valid_cards):
			Card.onCreateBaseFieldEffect(CHARMING_STANCE_FIELD_EFFECT_ID, -1, -1, self)
			valid_cards.append(Card)
			
		onPushAction(actions)
		onAbility()
		
# Guaranteed for 2 units, 10% chance to use for 1 unit
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	if active_effect_tiles.pickable_tiles.size() >= GUARANTEED_CHARMING_STANCE_UNIT_AMOUNT_AI:
		return active_effect_tiles.pickable_tiles.pick_random()
	elif active_effect_tiles.pickable_tiles.size() == 1 and Random.rollFloat(SINGLE_UNIT_CHANCE):
		return active_effect_tiles.pickable_tiles.pick_random()
	return null
		
func onSave() -> SavedDataCard:
	ability_save["valid_cards"] = valid_cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	valid_cards = valid_cards.map(func(x: int): return Game.onFindPublicIDObject(x))

func getDescription() -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Charming Stance")
	if active_effect != null:
		return Helper.getDescriptionNumeric(super(), [active_effect.charges], [["ABILITY ", ("[1]" if !ascended else "[2]")]])
	return super()

const IN_ALLY_WITH_BUFF_VISION_BONUS: float = 0.25
func onUnitSpecificTransforms(tiles_to_value: Dictionary, _DFL: DefaultFightLogic) -> void:
	for TransformTile: TileGD in tiles_to_value:
		var vision_bonus: float = valid_cards.filter(func(x: CardGD): return TransformTile in x.getVisibleGameObjects()).size() * IN_ALLY_WITH_BUFF_VISION_BONUS
		tiles_to_value[TransformTile] += vision_bonus
