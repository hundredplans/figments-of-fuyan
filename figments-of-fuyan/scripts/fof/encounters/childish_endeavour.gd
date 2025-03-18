extends EncounterGD

const MENTOR_BOON_ID: int = 16
const NURTURE_BOON_ID: int = 10
const PROGRESS_BELOW_WHERE_CAN_SHOW_UP: int = 6
const FLY_START_DELAY: float = 1

func canShowUp() -> bool:
	return anyRequirementMet() and Game.area.getProgress() <= PROGRESS_BELOW_WHERE_CAN_SHOW_UP
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		_: pass
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, screen: Control) -> void:
	match option.name:
		"Inform":
			var boon_data: SavedDataBoon = Random.getRandomFofInRarity(BoonInfo, Game.Rarities.COMMON)
			if boon_data != null:
				onPushAction(AddBoonAction.new(boon_data.id, boon_data.ascended))
		"Train":
			onPushAction(AddBoonAction.new(NURTURE_BOON_ID, false))
		"Mentor":
			onForceAction(AddBoonAction.new(MENTOR_BOON_ID, false))
			
			var mentor_boon: BoonGD = Game.getSaveFile().getBoon(MENTOR_BOON_ID)
			if mentor_boon != null:
				var Card: CardGD = mentor_boon.getPalmyCard()
			
				var CardUI: Control = Card.onCreateCardUI(screen, false)
				CardUI.setDisabled(true)
				CardUI.global_position = get_viewport().get_mouse_position() - (CardUI.size / 2) - Vector2(0, CardUI.size.y / 2)
				temp_disable_options.emit(true)
				
				await get_tree().create_timer(FLY_START_DELAY).timeout
				await Game.onFlyToUI(CardUI, screen.UI.getDeckPanel())
			
	onContinueToNextPage(option)
