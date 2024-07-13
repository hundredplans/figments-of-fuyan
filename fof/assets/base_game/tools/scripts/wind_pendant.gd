extends ToolGD

const SPEED: int = 1

func onTrigger(_Unit: UnitGD, trigger: int, args: Array) -> void:
	if _Unit == Unit and trigger == TriggerGD.AWAKEN:
		Unit.stats("speed", SPEED, AppliedByGD.new("Tool"))

func getDisabled(tool_ability_info: ToolAbilityInfoGD) -> bool:
	return tool_ability_info.charges == 0

func onAbilityTrigger(tool_ability_info: ToolAbilityInfoGD) -> void:
	Combat.onApplyBuffNextTurn(BuffInfoGD.new(Unit, AppliedByGD.new("Tool", Unit), "speed", SPEED))
	tool_ability_info.charges -= 1
