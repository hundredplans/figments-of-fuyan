extends CardGD

func onProcessAction(action: Action) -> void:
	if isValidOnHit(action):
		onPushAction(OnHitAction.new(self, action))

func onHit(damage_action: DamageAction, attack_action: AttackAction) -> void:
	var heal: int = damage_action.damage
	
	if heal > 0:
		var allies: Array = getVisibleFieldCards().filter(func(x: CardGD): return x.isAlly(team))
		var picked_allies: Array = []
		if !ascended and !allies.is_empty():
			picked_allies.append(allies.pick_random())
		elif ascended:
			picked_allies = allies
			
		var actions: Array = []
		for ally in picked_allies:
			onPushAction(StatAction.new(StatInfo.new(ally, Game.Stats.HEALTH, heal)))
