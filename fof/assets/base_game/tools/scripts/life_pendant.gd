extends ToolGD

const HEAL: int = 1
const HEALTH: int = 1

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if _Unit == Unit:
		if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
			Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), StatsGD.BOTH_HEALTH, HEALTH))
		elif trigger == TriggerGD.UNEQUIP_TOOL and args.Tool == self:
			Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), StatsGD.BOTH_HEALTH, -HEALTH))

func onAbilityTrigger(tool_ability_info: ToolAbilityInfoGD) -> void:
	Combat.onHeal(HealInfoGD.new(Unit, HEAL, AppliedByGD.new(AppliedByGD.TOOL, self)))
	tool_ability_info.charges -= 1
	VFX.onCreateUnitVFX(Unit, "Pendant", [1])
	
func onAfterDelay() -> void:
	VFX.onRemoveUnitVFX(Unit, "Pendant")
	
