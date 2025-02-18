extends CardGD

var rampage_charges: int
var trauma_charges: int
var bloodthirst_charges: int

func onLoadData(data: SavedData) -> void:
	super(data)
	onResetCharges()

func onAwaken() -> void:
	super()
	onResetCharges()

func onResetCharges() -> void:
	rampage_charges = 2 if !ascended else -1
	trauma_charges = 2 if !ascended else -1
	bloodthirst_charges = 2 if !ascended else -1

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action) and rampage_charges != 0:
		onPushAction(RampageAction.new(self, action))
	elif isValidTrauma(action) and trauma_charges != 0:
		onPushAction(TraumaAction.new(self, action))
	elif isValidBloodthirst(action) and bloodthirst_charges != 0:
		onPushAction(BloodthirstAction.new(self, action))
	
func onRampage(_action: DeathAction) -> void:
	onEffect()
	rampage_charges -= 1
	
func onTrauma(_action: DeathAction) -> void:
	onEffect()
	trauma_charges -= 1
	
func onBloodthirst(_action: DeathAction) -> void:
	onEffect()
	bloodthirst_charges -= 1
	
func onEffect() -> void:
	onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.MAX_HEALTH, 1)))
	onAbility()
	
func getDescription() -> String:
	return super() if ascended else ("RAMPAGE [%s]\nTRAUMA [%s]\n BLOODTHIRST[%s]:\nGain [1] HP" % [rampage_charges, trauma_charges, bloodthirst_charges])

func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	ability_save['trauma_charges'] = trauma_charges
	ability_save['bloodthirst_charges'] = bloodthirst_charges
	return super()

func onAscendedUpdated(state: bool) -> void:
	super(state)
	onResetCharges()
