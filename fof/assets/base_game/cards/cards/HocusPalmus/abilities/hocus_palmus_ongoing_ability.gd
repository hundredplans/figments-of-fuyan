extends OngoingAbilityGD

var on_delay_remove: bool = false
func onCocusCharges() -> String:
	for ability in Unit.abilities:
		if ability.ability_name == "Cocus Pocus" and ability.charges == 0:
			if affected_units.size() == 1:
				trigger_info.append([affected_units[0], false])
				on_delay_remove = true
				return "Return"
			return "Null"
	return "Continue"

func ChangeStat(_AppliedBy: AppliedByGD, stat: String) -> bool:
	var state: String = onCocusCharges()
	if state == "Return": return true
	if state == "Continue" and TriggerUnit != Unit and stat == "health":
		return onPickMostInjured()
	return false
				
func UnitDeath() -> bool:
	var state: String = onCocusCharges()
	if state == "Return": return true
	if state == "Continue":
		if TriggerUnit == Unit:
			for _Unit in affected_units: trigger_info.append([_Unit, false])
			return true
	elif TriggerUnit in affected_units:
		return onPickMostInjured()
	return false
	
func Arrive() -> bool:
	var state: String = onCocusCharges()
	if state == "Return": return true
	if state == "Continue" and TriggerUnit == Unit:
		return onPickMostInjured()
	return false
	
func onPickMostInjured() -> bool:
	var triggered: bool = false
	var highest_injury: int = 0
	if affected_units.size() == 1:
		if affected_units[0].health <= 0:
			trigger_info.append([affected_units[0], false])
			triggered = true
		else:
			highest_injury = affected_units[0].max_health - affected_units[0].health
			if highest_injury == 0:
				trigger_info.append([affected_units[0], false])
				triggered = true
			
	for _Unit in Units.on_units(TeamRelationGD.new(Unit.team)).filter(func(x: UnitGD): return x.health > 0):
		if _Unit.max_health - _Unit.health > highest_injury:
			if affected_units.size() == 1 and !triggered:
				trigger_info.append([affected_units[0], false])
			trigger_info.append([_Unit, true])
			return true
	return triggered

func onOngoingAbility() -> void:
	var AppliedBy := AppliedByGD.new("Ability", Unit)
	for info in trigger_info:
		var _Unit: UnitGD = info[0]
		if info[1]:
			LevelUI.UnitStatusOverlord.onAddUnitFX(_Unit, "CocusPocus", AppliedBy)
			VFX.onCreateCocusPocus(_Unit, self)
			affected_units.append(_Unit)
		else:
			LevelUI.UnitStatusOverlord.onRemoveUnitFX(_Unit, "CocusPocus", AppliedBy)
			affected_units.erase(_Unit)
			
			if !on_delay_remove: VFX.onRemoveCocusPocus(_Unit)
			else:
				on_delay_remove = false
				await Units.get_tree().create_timer(2.5).timeout
				VFX.onRemoveCocusPocus(_Unit)
	trigger_info = []
