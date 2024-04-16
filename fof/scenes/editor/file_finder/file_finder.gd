class_name FileFinderGD
extends Node

const CARDS_PATH: String = "res://assets/base_game/cards/cards/"
func onSearchCards(text: String, area: int) -> Array:
	var base_cards: Array = []
	for dir in DirAccess.get_directories_at(CARDS_PATH):
		for file in DirAccess.get_files_at(CARDS_PATH + dir):
			if file.begins_with("base_card"):
				var base_card: Resource = load(CARDS_PATH + dir + "/" + file)
				if base_card.area_id == area:
					if base_card is HeroCardGD:
						for card in base_card.base_cards: base_cards.append(card)
					else: base_cards.append(base_card)
	return base_cards.filter(func(base_card: BaseCardGD): return base_card.name.to_lower().begins_with(text.to_lower()))

