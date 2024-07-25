extends GameFXGD

var HighlightUnit: UnitGD
var extra_damage: int
var vfx_callable: Callable
var status_fx: StatusFXGD
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onAttack, TriggerGD.ON_ATTACK, TriggerGD.NULL),
		TriggerGD.new(self, Unit, onAfterAttack, TriggerGD.ON_AFTER_ATTACK, TriggerGD.NULL),
		TriggerGD.new(self, Unit, onRemoved, TriggerGD.REMOVE, TriggerGD.NULL)
	]
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.SUGORI_KNIFE)
	status_fx.setHighlightUnit(HighlightUnit)

func onAttack(trigger_info: OnAttackTriggerInfoGD) -> void:
	Unit.extra_damage += extra_damage
	vfx_callable.call(Unit)
	
func onAfterAttack() -> void:
	Unit.extra_damage -= extra_damage
	
func onRemoved() -> void:
	StatusManager.onRemoveStatusFX(status_fx)
