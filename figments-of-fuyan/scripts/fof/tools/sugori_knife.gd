extends ToolGD

const SUGORI_KNIFE_FIELD_EFFECT_ID: int = 1

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is DamageAction and action.owner is AttackAction and isValidSugoriKnife(action.Damager):
			onForceAction(ToolActivatedAction.new(self, action))
		elif action is GetDamageAction and action.damage_type == Game.DamageTypes.ATTACK and isValidSugoriKnife(action.Damager):
			action.onAdd(1)
	elif action.post:
		if ascended:
			if action is VisionNewUnitAction and action.Discoverer == Card and action.Discovered.isAlly(Card.team):
				if action.enter_vision: onAddFieldEffect(action.Discovered)
				else: onRemoveFieldEffect(action.Discovered)
			elif action is DeathAction and action.Defender == Card:
				onRemoveFieldEffects(action.game_objects_in_vision.filter(func(x: GameObjectGD): return x is CardGD and x.isAlly(Card.team)))

func isValidSugoriKnife(DamageCard: CardGD) -> bool:
	return DamageCard == Card or (ascended and DamageCard in Card.getVisibleFieldCardsAllies())

func onToolAction(action: DamageAction) -> void:
	for Defender in action.owner.Defenders.filter(func(x: GameObjectGD): return x is CardGD and x.isInjured() and x.isEnemy(Card.team)):
		action.damage += 1

func onToolEquipped() -> void:
	super()
			
func onToolHolderAwakened() -> void:
	super()
	if ascended:
		for FieldCard in Card.getVisibleFieldCardsAllies():
			onAddFieldEffect(FieldCard)
	
func onToolHolderDeath() -> void:
	super()
	if ascended:
		onRemoveFieldEffects(Card.getVisibleFieldCardsAllies())
	
func onReset(override: bool = false) -> void:
	super(override)
	if Card == null or !ascended: return
	
	onRemoveFieldEffects(Card.getVisibleFieldCardsAllies())
	
func onToolUnequipped() -> void:
	super()
	
func onRemoveFieldEffects(visible_field_cards: Array) -> void:
	if ascended:
		for FieldCard in visible_field_cards:
			onRemoveFieldEffect(FieldCard)
	
func onAddFieldEffect(FieldCard: CardGD) -> void:
	FieldCard.onCreateBaseFieldEffect(SUGORI_KNIFE_FIELD_EFFECT_ID, -1, -1, self)
	
func onRemoveFieldEffect(FieldCard: CardGD) -> void:
	FieldCard.onRemoveFieldEffectsByOwner(self)
	
