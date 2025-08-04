extends CardGD

const MINIMUM_TIER_VISION_HEAL: int = 3

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidOnHit(action):
		onPushAction(OnHitAction.new(self, action))

func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	var heal: int = damage_action.damage
	if heal > 0:
		var allies: Array = getVisibleFieldCards().filter(func(x: CardGD): return x != self and x.isAlly(team) and x.isHealable())
		var picked_allies: Array = []
		if tier < MINIMUM_TIER_VISION_HEAL and !allies.is_empty():
			picked_allies.append(allies.pick_random())
		else:
			picked_allies = allies
			
		onPushAction(HealAction.new(picked_allies.map(func(x: CardGD): return HealDatastore.new(x, heal))))
