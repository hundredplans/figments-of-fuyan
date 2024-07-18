extends ToolGD

const HEAL: int = 1
const HEALTH: int = 1

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if _Unit == Unit:
		if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
			Unit.stats("health", HEALTH, AppliedByGD.new(AppliedByGD.TOOL, self))
		elif trigger == TriggerGD.UNEQUIP_TOOL and args.Tool == self:
			Unit.stats("health", -HEALTH, AppliedByGD.new(AppliedByGD.TOOL, self))
			
func getDisabled(tool_ability_info: ToolAbilityInfoGD) -> bool:
	return tool_ability_info.charges == 0

func onAbilityTrigger(tool_ability_info: ToolAbilityInfoGD) -> void:
	Combat.onHeal(HealInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), HEAL))
	tool_ability_info.charges -= 1
	VFX.onCreateUnitVFX(Unit, "Pendant", [1])
	
func onAfterDelay() -> void:
	VFX.onRemoveUnitVFX(Unit, "Pendant")
	
