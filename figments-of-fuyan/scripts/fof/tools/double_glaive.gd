extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()

func onToolHolderAwakened() -> void: # Unit awakens
	super()
	
func onToolHolderDeath() -> void: # Unit dies
	super()
	
func onToolAscended(state: bool) -> void:
	super(state)
	
func onCardTurnPassed() -> void:
	super()
	
func onReset() -> void: # Level ends
	super()
