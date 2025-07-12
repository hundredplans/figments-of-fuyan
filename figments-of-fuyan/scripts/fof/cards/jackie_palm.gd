extends CardGD

var revenge_charges: int
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRevenge(action) and revenge_charges > 0:
		onPushAction(RevengeAction.new(self, action.owner, true))
	
func getDescription() -> String:
	return Helper.getDescription(super(), [revenge_charges])
	
func onRevenge(action: DamageAction) -> void:
	super(action)
	var palm_ids: Array = Helper.getFofInfoID(AreaInfo, 1).card_ids
	if getVisibleFieldCardsAllies().any(func(x: CardGD): return x.info.id in palm_ids):
		revenge_charges -= 1
		onPushAction(HealAction.new(HealDatastore.new(self, 1)))

func onRegularReset() -> void:
	super()
	revenge_charges = getDefaultCharges()
	
func getDefaultCharges() -> int:
	return 2

func onSave() -> SavedDataCard:
	ability_save['revenge_charges'] = revenge_charges
	return super()
