class_name ArmorGD extends TraitGD
	
func onProcessAction(action: Action) -> void:
	if !action.post:
		if action is DamageAction and Card in action.Defenders and action.damage_type != Game.DamageTypes.FALL_DAMAGE:
			action.setArmor(getArmor())
		elif action is GetDamageAction and Card == action.Defender and action.damage_type != Game.DamageTypes.FALL_DAMAGE:
			action.setArmor(getArmor())

func getDescription() -> String:
	return Helper.getDescription(super(), [getArmor()])

func getArmor() -> int:
	return getDisplayNumber()

func setArmor(armor: int) -> void:
	setDisplayNumber(armor)
