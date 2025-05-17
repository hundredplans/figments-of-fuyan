extends CardGD

var ability_turns_remaining: int
var affected_cards: Array = []
var affected_cards_public_ids: Array = []

const ARMOR_ID: int = 1
const DEFAULT_ABILITY_TURNS: int = 3
const ASCENDED_ABILITY_TURNS: int = 5
const ABILITY_DELAY: float = 2.0

func onProcessAction(action: Action) -> void:
	super(action)
	if ability_turns_remaining > 0 and isValidEndOfTurn(action):
		ability_turns_remaining = max(ability_turns_remaining - 1, 0)
		if ability_turns_remaining == 0:
			for Card: CardGD in affected_cards.duplicate():
				onRemoveFromAura(Card)
	
	if action.post:
		if ability_turns_remaining > 0 and card_place == Game.CardPlaces.FIELD:
			if action is VisionNewUnitAction and action.Discoverer == self and action.Discovered.isAlly(team) and action.Discovered != self:
				if action.enter_vision and action.Discovered not in affected_cards:
					onAddToAura(action.Discovered)
				elif !action.enter_vision and action.Discovered in affected_cards:
					onRemoveFromAura(action.Discovered)
				
func onAddToAura(Card: CardGD) -> void:
	affected_cards.append(Card)
	var trait_data := SavedDataArmor.new(ARMOR_ID, true, 0)
	trait_data.armor = 1
	
	var add_overworld_trait_action := AddOverworldTraitAction.new(Card, OverworldTrait.new(trait_data, OverworldTrait.AddedBy.JIBBEN, true), true)
	onPushAction(add_overworld_trait_action)
	
func onRemoveFromAura(Card: CardGD) -> void:
	affected_cards.erase(Card)
	onPushAction(RemoveOverworldTraitAction.new(Card, ARMOR_ID, OverworldTrait.AddedBy.JIBBEN))
					
func getDescription() -> String:
	return super()

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Blacksmith's Will":
		return ActiveEffectTiles.new([getTile()], [getTile()])
	return null
	
func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return false
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Blacksmith's Will":
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
		
		ability_turns_remaining = getDefaultCharges()
		var visible_allies: Array = getVisibleFieldCardsAllies()
		visible_allies.erase(self)
		for VisibleAlly: CardGD in visible_allies:
			onAddToAura(VisibleAlly)
			
		onPushAction(animation_action)
	
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	var ally_vision: Array = Game.getTeamVision(0)
	var tiles: Array = active_effect_tiles.pickable_tiles.filter(func(x: TileGD): return x in ally_vision)
	if !tiles.is_empty():
		return tiles.pick_random()
	return null

func getDefaultCharges() -> int:
	return ASCENDED_ABILITY_TURNS if getAscended() else DEFAULT_ABILITY_TURNS

func onRegularReset() -> void:
	super()
	affected_cards = []
	ability_turns_remaining = 0
	
func onSave() -> SavedDataCard:
	ability_save['affected_cards_public_ids'] = affected_cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	affected_cards = affected_cards_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
