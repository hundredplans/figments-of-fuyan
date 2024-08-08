extends GameFXGD

var Trinket: TrinketEffectGD
var status_fx: StatusFXGD
var unit_vfx: Node3D

var avoid_ready: bool = false
# The id within the trinket type
var trinket_inside_id: int = 0
enum {OFFENSIVE, DEFENSIVE, MISC, DEBUFF, SUPPORT}

func onCreateGFX() -> void:
	triggers += [TriggerGD.new(self, Unit, onRemove, TriggerGD.REMOVE, TriggerGD.NULL)]
	
	Trinket.setInfo(Unit, self)
	
	if !avoid_ready and Trinket.has_method("onReady"):
		Trinket.onReady()
		if !removed:
			status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.TRINKET, AppliedByGD.new(AppliedByGD.TRINKET, Trinket))
			unit_vfx = VFX.onCreateUnitVFX(Unit, "Trinket", [Trinket.trinket_id])
	
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	Trinket.onTrigger(_Unit, trigger, args)

func onRemove() -> void:
	StatusManager.onRemoveStatusFX(status_fx)
	VFX.onQuickRemoveUnitVFX(unit_vfx)
