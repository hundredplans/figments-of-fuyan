extends ToolGD

const HEAL: int = 1
const HEALTH: int = 1

func onTrigger(_Unit: UnitGD, trigger: int, args: Array) -> void:
	if _Unit == Unit and trigger == TriggerGD.AWAKEN:
		Unit.stats("health", HEALTH, AppliedByGD.new("Tool", Unit))

func getDisabled(tool_ability_info: ToolAbilityInfoGD) -> bool:
	return tool_ability_info.charges == 0

func onAbilityTrigger(tool_ability_info: ToolAbilityInfoGD) -> void:
	Combat.onHeal(HealInfoGD.new(Unit, AppliedByGD.new("Tool", Unit), HEAL))
	tool_ability_info.charges -= 1
