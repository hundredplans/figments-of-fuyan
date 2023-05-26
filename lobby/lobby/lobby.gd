extends Node

@onready var cards: Dictionary = on_initialize_cards()

func on_initialize_cards() -> Dictionary:
	var cards_path := "res://static_data/cards.json"
	var cards_as_string: String = FileAccess.get_file_as_string(cards_path)
	var cards_as_dict: Dictionary = JSON.parse_string(cards_as_string)
	
	for card in cards_as_dict.values():

		if card.aid and typeof(card.aid) != TYPE_ARRAY:
			card.aid = [card.aid]
			print(card.aid)
		
		card = convert_json_card_stats(card)
		
	print(cards_as_dict)
	return {}
	
func convert_json_card_stats(card: Dictionary) -> Dictionary:

	var stats := {"stat1": "att", "stat2": "hp", "stat3": "spd", "stat4": "nrg"}
	for stat in stats:
		if card[stat] != null:
			card[stats[stat]] = card[stat]
			card.erase(stat)
		
	return {}
