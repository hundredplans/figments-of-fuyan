extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidArrive(action):
		onPushAction(ArriveAction.new(self, action))
	elif isValidRampage(action):
		onPushAction(RampageAction.new(self, action))
	
func getDescription() -> String:
	return super()
	
func onArrivePre(_action: AwakenAction) -> void:
	pass

func onArrive(_action: AwakenAction) -> void:
	var damage_action := DamageAction.new(self, self, 2 if !ascended else 3)
	damage_action.setActionDelay(0.0)
	damage_action.setLockActionDelay(true)
	
	onPushAction(damage_action)

func onRampage(_action: DeathAction) -> void:
	var cards: Array = getVisibleFieldCardsAllies() + [self]
	onPushAction(HealAction.new(cards.map(func(x: CardGD): return HealDatastore.new(x, 1))))
	
