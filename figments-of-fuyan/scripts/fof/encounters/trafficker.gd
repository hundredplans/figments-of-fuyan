extends EncounterGD

const HANDY_SHILLINGS: int = 30
const PRESTIGE_SHILLINGS: int = 30
const FLY_START_DELAY: int = 1

func canShowUp() -> bool:
	return anyRequirementMet()
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		"Handy": return Game.save_file.getShillings() >= HANDY_SHILLINGS
		"Prestige": return Game.save_file.getShillings() >= PRESTIGE_SHILLINGS
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, screen: Control) -> void:
	var card_data: SavedDataCard
	var tool_data: SavedDataTool
	match option.name:
		"Handy":
			Game.save_file.onUpdateShillings(-HANDY_SHILLINGS)
			card_data = Random.getRandomFofInRarity(CardInfo, Game.Rarities.COMMON)
			tool_data = Random.getRandomFofInRarity(ToolInfo, Game.Rarities.RARE)
		"Prestige":
			Game.save_file.onUpdateShillings(-HANDY_SHILLINGS)
			card_data = Random.getRandomFofInRarity(CardInfo, Game.Rarities.RARE)
			tool_data = Random.getRandomFofInRarity(ToolInfo, Game.Rarities.COMMON)
	
	if card_data != null and tool_data != null:
		card_data.tool_data = tool_data
		var Card: CardGD = SavedData.onLoadModel(card_data, Game.save_file)
		Game.onAddToDeck(Card)
		
		var CardUI: Control = Card.onCreateCardUI(screen, false)
		CardUI.setDisabled(true)
		CardUI.global_position = get_viewport().get_mouse_position() - (CardUI.size / 2) - Vector2(0, CardUI.size.y / 2)
		temp_disable_options.emit(true)
		
		await get_tree().create_timer(FLY_START_DELAY).timeout
		await Game.onFlyToUI(CardUI, screen.UI.getDeckPanel())
			
	onContinueToNextPage(option)
