extends EncounterGD

const PAY_OPTION_SHILLINGS: int = 25
func canShowUp() -> bool:
	return anyRequirementMet()
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		"Climb": return Game.getDeckSize() > 1
		"Pay": return Game.save_file.getShillings() >= PAY_OPTION_SHILLINGS
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, screen: Control) -> void:
	match option.name:
		"Climb":
			temp_disable_options.emit(true)
			await Game.onRemoveCardWithAnimation(Game.getRandomNonChampionCard(), screen)
		"Pay": Game.save_file.onUpdateShillings(-PAY_OPTION_SHILLINGS)
	onContinueToNextPage(option)
	
