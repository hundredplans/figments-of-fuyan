extends BoonGD

var limited_abilities_placed: int
const MAX_LIMITED_ABILITY_PLACED: int = 4

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card.isAlly(0) and isCardLimitedAbility(action.Card):
			onPushAction(BoonActivatedAction.new(self, action))
			
		if limited_abilities_placed >= MAX_LIMITED_ABILITY_PLACED:
			if action is FinishAwakenAction:
				onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return super()

func onBoon(action: Action = null) -> void:
	if action is AwakenAction: limited_abilities_placed += 1
	elif action is FinishAwakenAction:
		onResetChargesInLevel()
		onPushAction(action.Card.getActiveAbilities().map(func(x: ActiveAbilityDatastore): return ChangeActiveEffectChargesAction.new(x, 1)))

func onBoonAdded() -> void:
	onResetCharges()
	
func onResetChargesInLevel() -> void:
	limited_abilities_placed = 0

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return limited_abilities_placed

func isCardLimitedAbility(Card: CardGD) -> bool:
	var abilities: Array = Card.info.active_abilities
	return !abilities.is_empty() and abilities.any(\
		func(x: ActiveAbilityDatastore): return (x.exists == Game.AscendedExists.BOTH and x.max_charges != -1)\
		or (!Card.ascended and x.exists == Game.AscendedExists.ONLY_DEFAULT and x.max_charges != -1)\
		or (Card.ascended and x.exists == Game.AscendedExists.ONLY_ASCENDED and x.ascended_max_charges != -1))
		
func onSave() -> SavedDataBoon:
	ability_save['limited_abilities_placed'] = limited_abilities_placed
	return super()
