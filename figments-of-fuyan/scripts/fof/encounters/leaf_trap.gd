extends EncounterGD

const PROGRESS_ABOVE_WHERE_CAN_SHOW_UP: int = 6
const PAY_OPTION_SHILLINGS: int = 12

func canShowUp() -> bool:
	return anyRequirementMet() and Game.area.getProgress() >= PROGRESS_ABOVE_WHERE_CAN_SHOW_UP
	
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
	
