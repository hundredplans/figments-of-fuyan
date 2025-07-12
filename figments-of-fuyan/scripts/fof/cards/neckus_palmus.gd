extends CardGD

var when_healed_charges: int
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidWhenHealed(action) and when_healed_charges > 0: # Has to be max hp
		onPushAction(WhenHealedAction.new(self, action))

func onWhenHealed(_action: StatAction) -> void:
	when_healed_charges -= 1
	var max_hp_gain: int = 1 if !ascended else 2
	onPushAction(StatAction.new(StatInfo.new(self, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [max_hp_gain, max_hp_gain])))

func getDescription() -> String:
	return Helper.getDescription(super(), [when_healed_charges])

func getDefaultCharges() -> int:
	return 3
	
func onSave() -> SavedDataCard:
	ability_save['when_healed_charges'] = when_healed_charges
	return super()
	
func onRegularReset() -> void:
	super()
	when_healed_charges = getDefaultCharges()
