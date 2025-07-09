extends CardGD

var ability_turns_remaining: int
var affected_cards: Array = []
var affected_cards_public_ids: Array = []
var blacksmith_will_public_ids: Array = []
var blacksmiths_aura_public_id: int

const ARMOR_ID: int = 1
const DEFAULT_ABILITY_TURNS: int = 3
const ASCENDED_ABILITY_TURNS: int = 5
const ABILITY_DELAY: float = 2.0
const BLACKSMITHS_WILL_ID: int = 17
const BLACKSMITHS_AURA_ID: int = 19

func onProcessAction(action: Action) -> void:
	super(action)
	if ability_turns_remaining > 0 and isValidEndOfTurn(action):
		ability_turns_remaining = max(ability_turns_remaining - 1, 0)
		if ability_turns_remaining == 0:
			for Card: CardGD in affected_cards.duplicate():
				onRemoveFromAura(Card)
			onPushAction(RemoveFieldEffectAction.new(Game.onFindPublicIDObject(blacksmiths_aura_public_id)))
		onUpdateFieldEffects()
		
	if action.post:
		if ability_turns_remaining > 0 and card_place == Game.CardPlaces.FIELD:
			if action is VisionNewUnitAction and action.Discoverer == self and action.Discovered.isAlly(team) and action.Discovered != self:
				if action.enter_vision and action.Discovered not in affected_cards:
					onAddToAura(action.Discovered)
				elif !action.enter_vision and action.Discovered in affected_cards:
					onRemoveFromAura(action.Discovered)
				
func onUpdateFieldEffects() -> void:
	for FieldEffect: FieldEffectGD in blacksmith_will_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x)):
		assert(FieldEffect != null)
		FieldEffect.onForceUpdateDisplayNumber()
		
	var FieldEffect: FieldEffectGD = Game.onFindPublicIDObject(blacksmiths_aura_public_id)
	assert(FieldEffect != null)
	FieldEffect.onForceUpdateDisplayNumber()
				
func onAddToAura(Card: CardGD) -> void:
	affected_cards.append(Card)
	var trait_data := SavedDataTrait.new(ARMOR_ID, true, 0, 1)
	
	var add_overworld_trait_action := AddOverworldTraitAction.new(Card, OverworldTrait.new(trait_data, OverworldTrait.AddedBy.JIBBEN, true), true)
	var add_field_effect_action: AddFieldEffectAction = Card.onCreateBaseFieldEffectAction(BLACKSMITHS_WILL_ID, -1, -1, self)
	var blacksmith_will_public_id: int = add_field_effect_action.FieldEffect.public_id
	blacksmith_will_public_ids.append(blacksmith_will_public_id)
	
	var actions: Array = [add_overworld_trait_action, add_field_effect_action]
	
	onPushAction(actions)
	
func onRemoveFromAura(Card: CardGD) -> void:
	affected_cards.erase(Card)
	var BlacksmithsWill: FieldEffectGD = Card.onFindFieldEffectsByOwner(self).filter(func(x: FieldEffectGD): return x.info.id == BLACKSMITHS_WILL_ID)[0]
	blacksmith_will_public_ids.erase(BlacksmithsWill.public_id)
	var actions: Array = [RemoveOverworldTraitAction.new(Card, ARMOR_ID, OverworldTrait.AddedBy.JIBBEN), RemoveFieldEffectAction.new(BlacksmithsWill)]
	onPushAction(actions)
					
func getDescription() -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Blacksmith's Will")
	if active_effect != null:
		return Helper.getDescriptionNumeric(super(), [active_effect.charges], [["ABILITY ", "[1]"]])
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
			
		var add_field_effect_action: AddFieldEffectAction = onCreateBaseFieldEffectAction(BLACKSMITHS_AURA_ID)
		blacksmiths_aura_public_id = add_field_effect_action.FieldEffect.public_id
		
		var actions: Array = [animation_action, add_field_effect_action]
		onPushAction(actions)
	
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
	ability_save['blacksmith_will_public_ids'] = blacksmith_will_public_ids
	ability_save['blacksmiths_aura_public_id'] = blacksmiths_aura_public_id
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	affected_cards = affected_cards_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
