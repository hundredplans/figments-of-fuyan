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

func onArrive(action: AwakenAction) -> void:
	var damage_action := DamageAction.new(self, self, 2)
	damage_action.setActionDelayWithOverride(0.0)
	onPushAction(damage_action)

func onRampage(action: DeathAction) -> void:
	var heal_amount: int = 1 if !ascended else 2
	var cards: Array = getVisibleFieldCardsAllies() + [self]
	onPushAction(StatAction.new(cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.HEALTH, heal_amount))))
