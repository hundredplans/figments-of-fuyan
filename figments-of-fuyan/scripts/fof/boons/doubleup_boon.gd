extends BoonGD

func getDefaultCharges() -> int:
	return 1 if tier == 1 else 2

func onBoonAdded() -> void:
	super()

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is StatAction and action.getCards().any(func(x: CardGD): return x.isAlly(0))\
		and !action.stat_infos.all(func(x: StatInfo): return x.values.all(func(y: int): return y <= 0)\
		or x.absolute or x.immutable or x.types.all(func(z: Game.Stats): return z == Game.Stats.HEALTH))\
		and charges > 0:
			onForceAction(BoonActivatedAction.new(self, action))
	
#func onAscend(state: bool) -> void:
	#super(state)
	#
	#if ascended: onPushAction(ChangeBoonChargesAction.new(self, 1))
	#else: onPushAction(ChangeBoonChargesAction.new(self, -1))

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [charges])

func onBoon(action: Action) -> void:
	onPushAction(ChangeBoonChargesAction.new(self, -1))
	var stat_infos: Array = action.stat_infos.filter(func(x: StatInfo): return x.Card.isAlly(0) and !x.absolute and !x.immutable)
	for stat_info in stat_infos:
		var values: Array = range(stat_info.values.size()).filter(func(i: int): return stat_info.values[i] > 0)
		for i in values:
			if stat_info.types[i] != Game.Stats.HEALTH: stat_info.values[i] *= 2
	
func getDisabled() -> bool:
	return charges == 0
	
