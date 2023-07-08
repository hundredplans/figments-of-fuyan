extends Control

var all_cards_path: String = "res://static_data/cards/all_cards.json"
var owned_cards_path: String = "res://static_data/cards/owned_cards.json"
@onready var all_cards: Dictionary = Helper.load_json(all_cards_path)
@onready var owned_cards: Dictionary = Helper.load_json(owned_cards_path)

var deck_manager_main_display: Dictionary = {
	"sort_type": "DoubleColumnsMaxEight", 
	"lifecycle": self, 
	"location": "DeckManagerMainDisplay",
}
signal send_cards_to_card_sorter
var current_sort: int = CLAN_SORT
enum {CLAN_SORT, ENERGY_SORT, RARITY_SORT}

var filter_settings: Dictionary = {
	"energy_filter": {"active": false},
	"rarity_filter": {"active": false},
	"hide_hero_cards": {"active": false},
	"show_unowned_cards": {"active": false},
	"show_scrap_cards": {"active": false},
}
func show_first_eight_cards():
	var i: int = 0
	var cards: Array = []
	for key in all_cards:
		if i < 9: 
			var card = Helper.create_max_card(all_cards[key])
			cards.append(card)
		i += 1
	
	send_cards_to_card_sorter.emit(cards, deck_manager_main_display)
