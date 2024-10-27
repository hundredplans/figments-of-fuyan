extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if (!ascended and action is AttackAction and Card in action.Defenders) or (ascended and Card.isValidRevenge(action)):
			onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, 1)))
	
func onToolEquipped() -> void:
	pass
	
func onToolUnequipped() -> void:
	super()
