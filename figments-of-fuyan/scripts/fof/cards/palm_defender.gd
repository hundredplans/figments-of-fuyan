extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidBloodthirst(action):
		var palm_cards: Array = Helper.getFofInfoID(AreaInfo, 1).card_ids
		if action.Defender.info.id in palm_cards:
			onPushAction(BloodthirstAction.new(self, action))
	
func getDescription() -> String:
	return super()

func onBloodthirst(_action: DeathAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.MAX_HEALTH, 1)))
