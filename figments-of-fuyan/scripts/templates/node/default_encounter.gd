extends EncounterGD

func canShowUp() -> bool:
	return anyRequirementMet()
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		_: pass
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, screen: Control) -> void:
	match option.name:
		_: pass
	onContinueToNextPage(option)
