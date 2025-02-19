extends MapNodeScreen

func onDimBackground() -> bool:
	return true

func onChoiceButtonPressed(identifier: String) -> void:
	var trait_data: SavedDataTrait
	match identifier:
		"Armor": trait_data = SavedDataArmor.new(1, true, 0, 1)
		"Mobile": trait_data = SavedDataTrait.new(3, true)
		"Resist": trait_data = SavedDataTrait.new(4, true)
		"Nothing": onFinished(); return

	var DeckScreen: Control = Game.onCreateDeckScreen(self, true, 1, onFilterCardsByTraitData.bind(trait_data))
	DeckScreen.selected.connect(onDeckScreenSelected.bind(trait_data))

func onFilterCardsByTraitData(CardUI: Control, trait_data: SavedDataTrait) -> bool:
	return CardUI.Card.getOverworldTraitByID(trait_data.id) != null

func onDeckScreenSelected(Card: CardGD, trait_data: SavedDataTrait) -> void:
	Card.onAddOverworldTrait(OverworldTrait.new(trait_data, OverworldTrait.AddedBy.NULL))
	onFinished()

func onFinished() -> void:
	finished.emit()
	queue_free()
