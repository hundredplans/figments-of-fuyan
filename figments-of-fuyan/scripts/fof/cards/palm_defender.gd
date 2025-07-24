extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidBloodthirst(action):
		var palm_cards: Array = Helper.getFofInfoID(AreaInfo, 1).card_ids
		if action.Damager.info.id in palm_cards:
			onPushAction(BloodthirstAction.new(self, action))

func onBloodthirst(_action: DeathAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(self, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [1, 1])))
