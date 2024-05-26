extends OngoingAbilityGD

@export var ATTACK: int = 1
@export var ATTACK_TO_BUFF: int = 1
func UnitDeath() -> bool: # has to unapply buff, which will in turn apply any other palmfessors
	if TriggerUnit == Unit:
		for _Unit in affected_units: trigger_info.append([_Unit, false])
		return true
	return false
	
func EnterVision() -> bool: # check if the new unit has to be buffed
	if TriggerUnit.attack == ATTACK_TO_BUFF and TriggerUnit != Unit and TriggerUnit.team == 0 and TriggerUnit not in affected_units:
		trigger_info.append([TriggerUnit, true])
		return true
	return false
	
func ExitVision() -> bool: # debuff the unit if it's already been buffed
	if TriggerUnit in affected_units:
		trigger_info.append([TriggerUnit, false])
		return true
	return false
	
func ChangeStat(AppliedBy: AppliedByGD, stat: String) -> bool: # weird one, fucks with debuffs and buffs, has to not trigger when palmfessor applies buff?
	if stat == "attack" and AppliedBy.Applier != Unit and TriggerUnit != Unit\
	and TriggerUnit.Tile in Unit.visible_tiles:
		if TriggerUnit in affected_units: trigger_info.append([TriggerUnit, false])
		elif TriggerUnit.attack == ATTACK_TO_BUFF: trigger_info.append([TriggerUnit, true])
		return true
	return false
	
func onOngoingAbility() -> void:
	var AppliedBy := AppliedByGD.new("Ability", Unit)
	for info in trigger_info: # [0] = Unit, [1] = apply buff / debuff
		var _Unit: UnitGD = info[0]
		if info[1]:
			LevelUI.UnitStatusOverlord.onAddUnitFX(_Unit, "PalmfessorOngoingAbility", AppliedBy)
			
			onGainStats(_Unit, "attack", ATTACK, AppliedBy)
			affected_units.append(_Unit)
		else:
			LevelUI.UnitStatusOverlord.onRemoveUnitFX(_Unit, "PalmfessorOngoingAbility", AppliedBy)
			onGainStats(_Unit, "attack", ATTACK * -1, AppliedBy)
			affected_units.erase(_Unit)
		
	trigger_info = []
