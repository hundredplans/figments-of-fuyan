extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRevenge(action):
		onPushAction(RevengeAction.new(self, action.owner, false))
	
func getDescription() -> String:
	return super()

func onRevenge(action: DamageAction) -> void:
	if action.Damager is CardGD and Game.isAdjacent(Tile, action.Damager.getTile()):
		onPushAction(DamageAction.new(self, action.Damager, 1, Game.DamageTypes.OTHER))
