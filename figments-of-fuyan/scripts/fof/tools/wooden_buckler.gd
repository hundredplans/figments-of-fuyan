extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if (!ascended and action is AttackAction and Card in action.Defenders) or (ascended and Card.isValidRevenge(action)):
			var stat_action := StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, 1))
			onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onToolAction(action: StatAction) -> void:
	onPushAction(action)
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()

func onToolHolderAwakened() -> void:
	super()
