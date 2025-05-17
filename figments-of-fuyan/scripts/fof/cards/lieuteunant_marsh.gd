extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidForceOnHit(action):
		onForceAction(OnHitAction.new(self, action))
	
func getDescription() -> String:
	return super()

func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	damage_action.damage += getVisibleFieldCardsAllies().size()
