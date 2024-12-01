extends EncounterGD

func canShowUp() -> bool:
	return allRequirementMet()
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		"Accept":
			var ids: Array = get_tree().get_nodes_in_group("DeckCardsGD").map(func(x: CardGD): return x.info.id)
			var dict: Dictionary = {}
			for id in ids: dict[id] = null
			
			return dict.keys().size() != ids.size()
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, screen: Control) -> void:
	match option.name:
		"Accept":
			var ids: Array = get_tree().get_nodes_in_group("DeckCardsGD").map(func(x: CardGD): return x.info.id)
			var dict: Dictionary = {}
			
			for id in ids:
				if !dict.has(id): dict[id] = 1
				else: dict[id] += 1
			
			var duplicate_ids: Array = dict.keys().filter(func(id: int): return dict[id] > 1)
			var DeckScreen := Game.onCreateDeckScreen(screen, true, 2, onFilterDuplicateCards.bind(duplicate_ids), onValidSelection)
			DeckScreen.selected.connect(onAccepted.bind(option, screen))
			return
	onContinueToNextPage(option)
	
func onFilterDuplicateCards(CardUI: Control, duplicate_ids: Array) -> bool:
	return CardUI.Card.info.id not in duplicate_ids
	
func onValidSelection(cards: Array) -> bool:
	return cards.all(func(x: CardGD): return x.info.id == cards[0].info.id)
	
func onAccepted(cards: Array, option: EncounterOptionDatastore, screen: Control) -> void:
	cards[0].onAscend(true)
	await Game.onRemoveCardWithAnimation(cards[1], screen)
	onContinueToNextPage(option)
