extends CardGD

const REVENGE_DELAY: float = 2.0
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRevenge(action):
		onPushAction(RevengeAction.new(self, action.owner))
	
func getDescription() -> String:
	return super()

func onRevenge(_action: DamageAction) -> void:
	var allies: Array = getVisibleFieldCardsAllies()
	if allies.is_empty(): return
	allies.shuffle()
	
	allies.sort_custom(func(x: CardGD, y: CardGD):\
		return Game.getCoordsDistance(x.getCoords(), getCoords()) < Game.getCoordsDistance(y.getCoords(), getCoords()))
	
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(REVENGE_DELAY)
	onPushAction([animation_action, StatAction.new(StatInfo.new(allies[0], Game.Stats.ATTACK, 1, 1))])
	
