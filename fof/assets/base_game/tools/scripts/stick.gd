extends ToolGD

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if Unit == _Unit:
		if trigger == TriggerGD.EQUIP_TOOL and args.Tool == self:
			Unit.extra_damage = 1
		elif trigger == TriggerGD.ON_AFTER_ATTACK:
			Unit.extra_damage = 0
			Tools.onBreak(self)
		
