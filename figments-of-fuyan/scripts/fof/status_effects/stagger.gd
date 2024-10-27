class_name StaggerGD extends StatusEffectGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
