extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is HealAction and action.hasCard(Card):
			onForceAction(ToolActivatedAction.new(self, action))
	
func onToolAction(action: HealAction) -> void:
	for heal_datastore: HealDatastore in action.heal_datastores.filter(func(x: HealDatastore): return x.Card == Card):
		heal_datastore.heal *= 2
	
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
	
func onReset(override: bool = false) -> void: # Level ends
	super(override)
