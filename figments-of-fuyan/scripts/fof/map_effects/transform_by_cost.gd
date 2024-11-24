extends MapEffectGD

var NewCard: CardGD
func onPickup(Card: CardGD, save_file: SaveFileGD) -> void:
	var cards: Array = Helper.getFofInfoArray(CardInfo)
	cards = cards.filter(func(x: CardInfo):\
		return x != Card.info\
		and x.rarity in [Game.Rarities.COMMON, Game.Rarities.RARE, Game.Rarities.EXALT]\
		and x.energy == Card.energy)
		
	if !cards.is_empty():
		var new_card_info: CardInfo = cards.pick_random()
		var new_card_data: SavedDataCard = new_card_info.saved_data.new(new_card_info.id, true)
		var tool_data: SavedDataTool = null if Card.getTool() == null else Card.getTool().onSave()
		new_card_data.tool_data = tool_data
		new_card_data.ascended = Card.ascended
		
		NewCard = SavedData.onLoadModel(new_card_data, save_file)
		Card.queue_free()
		Game.onAddToDeck(NewCard)
