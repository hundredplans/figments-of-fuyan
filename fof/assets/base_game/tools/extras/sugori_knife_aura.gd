extends AuraGD

var extra_damage: int = 0
var vfx_callable: Callable
var affected_gfx: Array = []

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	match trigger:
		TriggerGD.ADD_ABILITY:
			if Unit == AuraUnit and args.ability == self:
				for _Unit in AuraUnit.getVisibleAllies().filter(func(x: UnitGD): return x not in affected_units):
					onApply(_Unit)
		TriggerGD.ENTER_VISION:
			if Unit == AuraUnit and args.Unit.team == AuraUnit.team and args.Unit not in affected_units:
				onApply(args.Unit)
		TriggerGD.EXIT_VISION:
			if Unit == AuraUnit and args.Unit in affected_units:
				onUnapply(args.Unit)
		TriggerGD.REMOVE_ABILITY:
			if Unit == AuraUnit and args.ability == self:
				for _Unit in affected_units.duplicate(): onUnapply(_Unit)

func onApply(Unit: UnitGD) -> void:
	var gfx: GameFXGD = GameEffects.addGFX(Unit, GameFXGD.SUGORI_KNIFE, {"vfx_callable": vfx_callable, "extra_damage": extra_damage, "HighlightUnit": AuraUnit})
	affected_units.append(Unit)
	affected_gfx.append(gfx)
	
func onUnapply(Unit: UnitGD) -> void:
	var gfx: GameFXGD = affected_gfx[affected_units.find(Unit)]
	GameEffects.onRemoveFX(gfx)
	affected_units.erase(Unit)
	affected_gfx.erase(gfx)
	
