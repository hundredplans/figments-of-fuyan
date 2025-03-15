extends CardGD

var rampage_charges: int = 3
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action) and rampage_charges != 0:
		onPushAction(RampageAction.new(self, action))
	
func onRampage(death_action: DeathAction) -> void:
	onAbility()
	
	var enemies: Array = Game.getAdjacentTiles(death_action.Tile).map(func(x: TileGD): return Game.getFieldCard(x))\
		.filter(func(x: CardGD): return x != null and isEnemy(x.team))
	
	onPushAction(DamageAction.new(self, enemies, attack, Game.DamageTypes.OTHER))
	if rampage_charges > 0:
		rampage_charges -= 1

func onResetCharges() -> void:
	rampage_charges = 3 if !ascended else -1

func getDescription() -> String:
	if !ascended:
		return Helper.getDescriptionNumeric(super(), [rampage_charges], [["RAMPAGE ", "[3]"]])
	return super()

func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	return super()
	
func onAwaken() -> void:
	super()
	onResetCharges()

func onFofInit() -> void:
	super()
	onResetCharges()

func onRegularReset() -> void:
	super()
	onResetCharges()
	
func onAscendedUpdated(state: bool) -> void:
	super(state)
	onResetCharges()
