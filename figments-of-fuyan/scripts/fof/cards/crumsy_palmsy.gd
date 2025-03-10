extends CardGD

var rampage_charges: int
var trauma_charges: int
var bloodthirst_charges: int

func onAwaken() -> void:
	super()
	onResetCharges()

func onFofInit() -> void:
	super()
	onResetCharges()

func onReset(override: bool = false) -> void:
	super(override)
	onResetCharges()
	
func onAscendedUpdated(state: bool) -> void:
	super(state)
	onResetCharges()

func onResetCharges() -> void:
	rampage_charges = 1 if !ascended else 2
	trauma_charges = 1 if !ascended else 2
	bloodthirst_charges = 1 if !ascended else 2

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
	if rampage_charges > 0:
		rampage_charges -= 1
	
func onTrauma(_action: DeathAction) -> void:
	onEffect()
	if trauma_charges > 0:
		trauma_charges -= 1
	
func onBloodthirst(_action: DeathAction) -> void:
	onEffect()
	if bloodthirst_charges > 0:
		bloodthirst_charges -= 1
	
func onEffect() -> void:
	onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.MAX_HEALTH, 1)))
	onAbility()
	
func getDescription() -> String:
	return ("RAMPAGE [%s]\nTRAUMA [%s]\n BLOODTHIRST[%s]:\nGain [1] HP" % [rampage_charges, trauma_charges, bloodthirst_charges])

func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	ability_save['trauma_charges'] = trauma_charges
	ability_save['bloodthirst_charges'] = bloodthirst_charges
	return super()
	
