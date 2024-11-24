extends BoonGD

var doubleup_charges: int

func onResetCharges() -> void:
	doubleup_charges = 1 if !ascended else 2

func onBoonAdded() -> void:
	onResetCharges()

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is StatAction and action.getCards().any(func(x: CardGD): return x.isAlly(0))\
		and !action.stat_infos.all(func(x: StatInfo): return x.values.all(func(y: int): return y <= 0)\
		or x.absolute or x.immutable or x.types.all(func(z: Game.Stats): return z == Game.Stats.HEALTH))\
		and doubleup_charges > 0:
			onForceAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)
	
	if ascended: doubleup_charges += 1
	else: doubleup_charges = max(doubleup_charges - 1, 0)

func getDescription() -> String:
	var square_bracket_number: String = "[1]" if !ascended else "[2]"
	return Helper.getDescriptionNumeric(super(), [doubleup_charges], [["Your next ", square_bracket_number]])

func onBoon(action: Action) -> void:
	doubleup_charges -= 1
	var stat_infos: Array = action.stat_infos.filter(func(x: StatInfo): return x.Card.isAlly(0) and !x.absolute and !x.immutable)
	for stat_info in stat_infos:
		var values: Array = range(stat_info.values.size()).filter(func(i: int): return stat_info.values[i] > 0)
		for i in values:
			if stat_info.types[i] != Game.Stats.HEALTH: stat_info.values[i] *= 2
	
func onSave() -> SavedDataBoon:
	ability_save["doubleup_charges"] = doubleup_charges
	return super()
	
func getDisabled() -> bool:
	return doubleup_charges == 0
	
func getCharges() -> int:
	return doubleup_charges
