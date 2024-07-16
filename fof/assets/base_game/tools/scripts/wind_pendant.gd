extends ToolGD

const SPEED: int = 1

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if _Unit == Unit:
		if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
			Unit.stats("full_speed", SPEED, AppliedByGD.new("Tool"))
		elif trigger == TriggerGD.UNEQUIP_TOOL and args.Tool == self:
			Unit.stats("full_speed", -SPEED, AppliedByGD.new("Tool"))

func getDisabled(tool_ability_info: ToolAbilityInfoGD) -> bool:
	return tool_ability_info.charges == 0

func onAbilityTrigger(tool_ability_info: ToolAbilityInfoGD) -> void:
	Combat.onApplyBuffNextTurn(BuffInfoGD.new(Unit, AppliedByGD.new("Tool", Unit), "speed", SPEED))
	tool_ability_info.charges -= 1
	VFX.onCreateUnitVFX(Unit, "Pendant", [6])
	
func onAfterDelay() -> void:
	VFX.onRemoveUnitVFX(Unit, "Pendant")
	
