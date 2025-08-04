extends ToolGD

const SUGORI_KNIFE_FIELD_EFFECT_ID: int = 1
const MINIMUM_TIER_VISION: int = 4
const MINIMUM_TIER_RANGE: int = 2

const TIER_TWO_RANGE: int = 1
const TIER_THREE_RANGE: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is DamageAction and action.owner is AttackAction and isValidSugoriKnife(action.Damager):
			onForceAction(ToolActivatedAction.new(self, action))
		elif action is GetDamageAction and action.damage_type == Game.DamageTypes.ATTACK and isValidSugoriKnife(action.Damager):
			action.onAdd(1)
	elif action.post:
		if tier >= MINIMUM_TIER_VISION:
			if action is VisionNewUnitAction and action.Discoverer == Card and action.Discovered.isAlly(Card.team):
				if action.enter_vision: onAddFieldEffect(action.Discovered)
				else: onRemoveFieldEffect(action.Discovered)
			elif action is DeathAction and action.Defender == Card:
				onRemoveFieldEffects(action.game_objects_in_vision.filter(func(x: GameObjectGD): return x is CardGD and x.isAlly(Card.team)))
		elif tier >= MINIMUM_TIER_RANGE:
			if action is DeathAction and action.Defender == Card:
				onRemoveFieldEffects(getAdjacentOrCloserAllies(action.Tile))
			elif action is OccupyAction and Card.isAlly(action.Card.getTeam()):
				onUpdateFieldEffectsForRange()

func isValidSugoriKnife(DamageCard: CardGD) -> bool:
	return DamageCard == Card or (tier >= MINIMUM_TIER_VISION and DamageCard in Card.getVisibleFieldCardsAllies())

func onToolAction(action: DamageAction) -> void:
	for Defender in action.owner.Defenders.filter(func(x: GameObjectGD): return x is CardGD and x.isInjured() and x.isEnemy(Card.team)):
		action.damage += 1

func onRetiered(_tier: int) -> void:
	super(_tier)
	if tier >= MINIMUM_TIER_VISION:
		onUpdateFieldEffectsForVision()
	elif tier >= MINIMUM_TIER_RANGE: onUpdateFieldEffectsForRange()
	else: onRemoveFieldEffects(Game.getAllyUnits(Card.getTeam()))
			
func onToolHolderAwakened() -> void:
	super()
	if tier >= MINIMUM_TIER_VISION:
		for FieldCard in Card.getVisibleFieldCardsAllies():
			onAddFieldEffect(FieldCard)
	elif tier >= MINIMUM_TIER_RANGE:
		for FieldCard: CardGD in getAdjacentOrCloserAllies():
			onAddFieldEffect(FieldCard)
	
func onToolHolderDeath() -> void:
	super()
	if tier >= MINIMUM_TIER_VISION:
		onRemoveFieldEffects(Card.getVisibleFieldCardsAllies())
	elif tier >= MINIMUM_TIER_RANGE:
		onRemoveFieldEffects(getAdjacentOrCloserAllies())
		
func getAdjacentOrCloserAllies(StartTile: TileGD = Card.getTile()) -> Array:
	var allies: Array = Game.getAllyUnits(Card.getTeam())
	var tiles: Array = Game.getAdjacentOrCloserTiles(StartTile, getTierRange())
	return allies.filter(func(x: CardGD): return x.getTile() in tiles)
	
func onReset(override: bool = false) -> void:
	super(override)
	if Card == null: return
	
	if tier >= MINIMUM_TIER_VISION:
		onRemoveFieldEffects(Card.getVisibleFieldCardsAllies())
	elif tier >= MINIMUM_TIER_RANGE:
		onRemoveFieldEffects(getAdjacentOrCloserAllies())
	
func onToolUnequipped() -> void:
	super()
	
func onRemoveFieldEffects(visible_field_cards: Array) -> void:
	for FieldCard in visible_field_cards:
		onRemoveFieldEffect(FieldCard)
	
func onAddFieldEffect(FieldCard: CardGD) -> void:
	FieldCard.onCreateBaseFieldEffect(SUGORI_KNIFE_FIELD_EFFECT_ID, -1, -1, self)
	
func onRemoveFieldEffect(FieldCard: CardGD) -> void:
	FieldCard.onRemoveFieldEffectsByOwner(self)
	
func onUpdateFieldEffectsForRange() -> void:
	var existing_allies: Array = Game.getAllyUnits(Card.getTeam()).filter(isValidExistingAlly)
	for ExistingAlly: CardGD in existing_allies.duplicate():
		if !Game.isAdjacentOrCloser(ExistingAlly.getTile(), Card.getTile(), getTierRange()):
			onRemoveFieldEffect(ExistingAlly)
			existing_allies.erase(ExistingAlly)
			
	for FieldCard: CardGD in getAdjacentOrCloserAllies().filter(func(x: CardGD): return x not in existing_allies):
		onAddFieldEffect(FieldCard)
		
func onUpdateFieldEffectsForVision() -> void:
	var existing_allies: Array = Game.getAllyUnits(Card.getTeam()).filter(isValidExistingAlly)
	for FieldCard: CardGD in Card.getVisibleFieldCardsAllies().filter(func(x: CardGD): return x not in existing_allies):
		onAddFieldEffect(FieldCard)
	
func isValidExistingAlly(AllyCard: CardGD) -> bool:
	var field_effects: Array = AllyCard.getFieldEffectsById(SUGORI_KNIFE_FIELD_EFFECT_ID)
	if field_effects.is_empty(): return false
	return field_effects.any(func(x: FieldEffectGD): return x.getFofObject() == self)
	
func getTierRange() -> int:
	match tier:
		2: return TIER_TWO_RANGE
		3: return TIER_THREE_RANGE
	return -1
