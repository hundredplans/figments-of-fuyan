extends ToolGD

const SPEED: int = 1

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if _Unit == Unit:
		var AppliedBy := AppliedByGD.new(AppliedByGD.TOOL, self)
		if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
			Unit.stats("full_speed", SPEED, AppliedBy)
		elif trigger == TriggerGD.UNEQUIP_TOOL and args.Tool == self:
			Unit.stats("full_speed", -SPEED, AppliedBy)

func getDisabled(tool_ability_info: ToolAbilityInfoGD) -> bool:
	return tool_ability_info.charges == 0

func onAbilityTrigger(tool_ability_info: ToolAbilityInfoGD) -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), StatsGD.BOTH_SPEED, SPEED, 1))
	tool_ability_info.charges -= 1
	VFX.onCreateUnitVFX(Unit, "Pendant", [6])
	
func onAfterDelay() -> void:
	VFX.onRemoveUnitVFX(Unit, "Pendant")
	
