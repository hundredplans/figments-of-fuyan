class_name MobileGD extends TraitGD

func onProcessAction(action: Action) -> void:
	if !action.post:
		if action is StatAction and action.owner is AttackAction and action.GameObject == Card:
			action.onFailAction()
