extends AuraGD

@export var ATTACK: int = 1
var status_fxs: Array[StatusFXGD] = []
# Buff applied has to be the exact same as unapplied
var affected_buffs: Array = []

var has_last_willed: bool = false
func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if !has_last_willed:
		match trigger:
			TriggerGD.STAT_CHANGE: 
				if !AuraUnit.is_dead and Unit != AuraUnit and Unit.team == AuraUnit.team and Unit.Tile in AuraUnit.visible_tiles\
				and args.stat_info.stat_type == StatsGD.ATTACK and args.stat_info.AppliedBy.Applier != AuraUnit:
					if Unit.attack != 1 and Unit in affected_units: onUnapply(Unit)
					elif Unit.attack == 1 and Unit not in affected_units: onApply(Unit)
					
			TriggerGD.LAST_WILL:
				if Unit in affected_units: onUnapply(Unit)
				elif Unit == AuraUnit:
					for _Unit in affected_units.duplicate(): onUnapply(_Unit)
					has_last_willed = true
			
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
	
	
#func UnitDeath() -> bool: # has to unapply buff, which will in turn apply any other palmfessors
	#if TriggerUnit == Unit:
		#for _Unit in affected_units: trigger_info.append([_Unit, false])
		#return true
	#return false
	#
#func EnterVision() -> bool: # check if the new unit has to be buffed
	#if TriggerUnit.attack == ATTACK_TO_BUFF and TriggerUnit != Unit and TriggerUnit.team == Unit.team and TriggerUnit not in affected_units:
		#trigger_info.append([TriggerUnit, true])
		#return true
	#return false
	#
#func ExitVision() -> bool: # debuff the unit if it's already been buffed
	#if TriggerUnit in affected_units:
		#trigger_info.append([TriggerUnit, false])
		#return true
	#return false
	#
#func ChangeStat(AppliedBy: AppliedByGD, stat: String) -> bool: # weird one, fucks with debuffs and buffs, has to not trigger when palmfessor applies buff?
	#if stat == "attack" and AppliedBy.Applier != Unit and TriggerUnit != Unit\
	#and TriggerUnit.Tile in Unit.visible_tiles and TriggerUnit.team == Unit.team:
		#if TriggerUnit in affected_units: trigger_info.append([TriggerUnit, false])
		#elif TriggerUnit.attack == ATTACK_TO_BUFF: trigger_info.append([TriggerUnit, true])
		#return true
	#return false
	#

#func onOngoingAbility() -> void:
	#var AppliedBy := AppliedByGD.new(AppliedByGD.ABILITY, Unit)
	#for info in trigger_info: # [0] = Unit, [1] = apply buff / debuff
		#var _Unit: UnitGD = info[0]
		#if info[1]:
			#var status_fx: StatusFXGD = StatusManager.onCreateStatusFX(_Unit, StatusFXInfoGD.IDS.PALMFESSOR_AURA, AppliedBy)
			#status_fxs.append(status_fx)
			#status_fx.setHighlightUnit(Unit)
			#Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.ATTACK, ATTACK))
			#Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.ATTACK, ATTACK))
			#affected_units.append(_Unit)
		#else:
			#StatusManager.onRemoveStatusFX(onFindStatusFXS(_Unit, status_fxs))
			#Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.ATTACK, ATTACK * -1))
			#affected_units.erase(_Unit)
		#
	#trigger_info = []
