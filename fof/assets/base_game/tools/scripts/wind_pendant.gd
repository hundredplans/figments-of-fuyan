extends ToolGD

const SPEED: int = 1

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if _Unit == Unit:
		if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
			Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), StatsGD.BOTH_SPEED, SPEED))
		elif trigger == TriggerGD.UNEQUIP_TOOL and args.Tool == self:
			Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), StatsGD.BOTH_SPEED, -SPEED))

func getDisabled(tool_ability_info: ToolAbilityInfoGD) -> bool:
	return tool_ability_info.charges == 0

func onAbilityTrigger(tool_ability_info: ToolAbilityInfoGD) -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), StatsGD.BOTH_SPEED, SPEED, 1))
	tool_ability_info.charges -= 1
	VFX.onCreateUnitVFX(Unit, "Pendant", [6])
	
func onAfterDelay() -> void:
	VFX.onRemoveUnitVFX(Unit, "Pendant")
	
