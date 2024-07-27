extends AuraGD

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if getCocusPocusCharges() > 0:
		match trigger:
			TriggerGD.STAT_CHANGE:
				if AuraUnit != Unit and !AuraUnit.is_dead and !Unit.is_dead and Unit.team == AuraUnit.team and \
				args.stat_info.getGeneralStatType() == StatsGD.BOTH_HEALTH:
					onCalculateMostInjured()
					
			TriggerGD.REMOVE_ABILITY:
				if Unit == AuraUnit and args.ability == self: onUnapply()
				
			TriggerGD.LAST_WILL:
				if Unit == getMostInjured():
					onUnapply()
					onCalculateMostInjured()

func onFindCocusPocus() -> AbilityGD:
	for ability in AuraUnit.abilities:
		if ability.ability_name == "Cocus Pocus":
			return ability
	return null
	
func getCocusPocusCharges() -> int:
	var cocus_pocus: AbilityGD = onFindCocusPocus()
	if cocus_pocus != null:
		return cocus_pocus.charges
	return 0
	
func getMostInjured() -> UnitGD:
	if !affected_units.is_empty(): return affected_units[0]
	return null
	
func getInjury() -> int:
	var Unit: UnitGD = getMostInjured()
	if Unit != null: return Unit.max_health - Unit.health
	return 0
	
func onCalculateMostInjured() -> void:
	var highest_injury: Dictionary = {"Unit": null, "injury": 0}
	for Unit in Units.on_units(TeamRelationGD.new(AuraUnit.team)):
		var new_injury: int = Unit.max_health - Unit.health
		if new_injury > highest_injury.injury:
			highest_injury.Unit = Unit
			highest_injury.injury = new_injury
			
	var old_highest_injury: int = getInjury()
	if highest_injury.injury > old_highest_injury:
		onUnapply()
		onApply(highest_injury.Unit)

var status_fx: StatusFXGD
func onUnapply() -> void:
	var Unit: UnitGD = getMostInjured()
	if Unit != null:
		affected_units.erase(Unit)
		StatusManager.onRemoveStatusFX(status_fx)
	
func onApply(Unit: UnitGD) -> void:
	var AppliedBy := AppliedByGD.new(AppliedByGD.ABILITY, AuraUnit)
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.COCUS_POCUS, AppliedBy)
	status_fx.setHighlightUnit(AuraUnit)
	affected_units.append(Unit)
	
	#
#func onOngoingAbility() -> void:
	#var AppliedBy := AppliedByGD.new(AppliedByGD.ABILITY, Unit)
	#for info in trigger_info:
		#var _Unit: UnitGD = info[0]
		#if info[1]:
			#var status_fx: StatusFXGD = StatusManager.onCreateStatusFX(_Unit, StatusFXInfoGD.IDS.COCUS_POCUS, AppliedBy, Unit)
			#status_fxs.append(status_fx)
			#status_fx.onAfterSetInfo()
			#VFX.onCreateCocusPocus(_Unit, Unit)
			#affected_units.append(_Unit)
		#else:
			#StatusManager.onRemoveStatusFX(onFindStatusFXS(_Unit, status_fxs))
			#affected_units.erase(_Unit)
			#
			#if !on_delay_remove: VFX.onRemoveCocusPocus(_Unit, Unit)
			#else:
				#on_delay_remove = false
				#await Units.get_tree().create_timer(2.5).timeout
				#VFX.onRemoveCocusPocus(_Unit, Unit)
	#trigger_info = []
	
	#
#func onCocusCharges() -> String:
	#for ability in Unit.abilities:
		#if ability.ability_name == "Cocus Pocus" and ability.charges == 0:
			#if affected_units.size() == 1:
				#trigger_info.append([affected_units[0], false])
				#on_delay_remove = true
				#return "Return"
			#return "Null"
	#return "Continue"
#
#func ChangeStat(_AppliedBy: AppliedByGD, stat: String) -> bool:
	#var state: String = onCocusCharges()
	#if state == "Return": return true
	#if state == "Continue" and TriggerUnit != Unit and stat == "health":
		#return onPickMostInjured()
	#return false
				#
#func UnitDeath() -> bool:
	#var state: String = onCocusCharges()
	#if state == "Return": return true
	#if state == "Continue":
		#if TriggerUnit == Unit:
			#for _Unit in affected_units: trigger_info.append([_Unit, false])
			#return true
	#elif TriggerUnit in affected_units:
		#return onPickMostInjured()
	#return false
	#
#func Arrive() -> bool:
	#var state: String = onCocusCharges()
	#if state == "Return": return true
	#if state == "Continue" and TriggerUnit == Unit:
		#return onPickMostInjured()
	#return false
	#
#func onPickMostInjured() -> bool:
	#var triggered: bool = false
	#var highest_injury: int = 0
	#if affected_units.size() == 1:
		#if affected_units[0].health <= 0:
			#trigger_info.append([affected_units[0], false])
			#triggered = true
		#else:
			#highest_injury = affected_units[0].max_health - affected_units[0].health
			#if highest_injury == 0:
				#trigger_info.append([affected_units[0], false])
				#triggered = true
			#
	#for _Unit in Units.on_units(TeamRelationGD.new(Unit.team)).filter(func(x: UnitGD): return x.health > 0):
		#if _Unit.max_health - _Unit.health > highest_injury:
			#if affected_units.size() == 1 and !triggered:
				#trigger_info.append([affected_units[0], false])
			#trigger_info.append([_Unit, true])
			#return true
	#return triggered
#
