extends GameFXGD

var Trinket: TrinketEffectGD
var status_fx: StatusFXGD

var trinket_id: int = 0
# The id within the trinket type
var trinket_inside_id: int = 0
enum {OFFENSIVE, DEFENSIVE, MISC, DEBUFF, SUPPORT}

func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.REMOVE, TriggerGD.NULL)
	]
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.TRINKET, AppliedByGD.new(AppliedByGD.TRINKET, Trinket))
	Trinket.setInfo(Unit, self)
	Trinket.onReady()
	
func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	Trinket.onTrigger(Unit, trigger, args)

func onRemove() -> void:
	StatusManager.onRemoveStatusFX(status_fx)
