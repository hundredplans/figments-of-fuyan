extends AuraGD

@export var ATTACK: int = 1
var status_fxs: Array[StatusFXGD] = []
# Buff applied has to be the exact same as unapplied
var affected_buffs: Array = []

var ability_removed: bool = false
func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if !ability_removed:
		match trigger:
			TriggerGD.STAT_CHANGE: 
				if !AuraUnit.is_dead and Unit != AuraUnit and Unit.team == AuraUnit.team and Unit.Tile in AuraUnit.visible_tiles\
				and args.stat_info.stat_type == StatsGD.ATTACK and args.stat_info.AppliedBy.Applier != AuraUnit:
					if Unit.attack != 1 and Unit in affected_units: onUnapply(Unit)
					elif Unit.attack == 1 and Unit not in affected_units: onApply(Unit)
					
			TriggerGD.LAST_WILL:
				if Unit in affected_units: onUnapply(Unit)
				
			TriggerGD.REMOVE_ABILITY:
				if Unit == AuraUnit and args.ability == self:
					for _Unit in affected_units.duplicate(): onUnapply(_Unit)
					ability_removed = true
			
			TriggerGD.EXIT_VISION:
				if Unit == AuraUnit and args.Unit in affected_units: onUnapply(args.Unit)
		
			TriggerGD.ENTER_VISION:
				if Unit == AuraUnit and args.Unit not in affected_units and args.Unit.attack == 1 and Unit.team == AuraUnit.team:
					onApply(args.Unit)

func onApply(Unit: UnitGD) -> void:
	var AppliedBy := AppliedByGD.new(AppliedByGD.ABILITY, AuraUnit)
	var stat_info := StatInfoGD.new(Unit, AppliedBy, StatsGD.ATTACK, ATTACK)
	Units.changeStats(stat_info)
	affected_units.append(Unit)
	affected_buffs.append(stat_info)
	var status_fx: StatusFXGD = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.PALMFESSOR_AURA, AppliedBy)
	status_fxs.append(status_fx)
	status_fx.setHighlightUnit(AuraUnit)

func onUnapply(Unit: UnitGD) -> void:
	var stat_info: StatInfoGD = affected_buffs[affected_units.find(Unit)]
	Units.changeStats(stat_info.getReverse())
	affected_units.erase(Unit)
	affected_buffs.erase(stat_info)
	StatusManager.onRemoveStatusFX(onFindStatusFXS(Unit, status_fxs))

