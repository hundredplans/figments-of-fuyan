extends Node

@onready var cards: Dictionary = on_initialize_cards()
func on_initialize_cards() -> Dictionary:
	var cards_path := "res://static_data/cards.json"
	var cards_as_string: String = FileAccess.get_file_as_string(cards_path)
	var cards_as_dict: Dictionary = JSON.parse_string(cards_as_string)
	
	for card in cards_as_dict.values():

		if card.aid and typeof(card.aid) != TYPE_ARRAY:
			card.aid = [card.aid]
		
		card = convert_json_card_stats(card)
		
	return cards_as_dict
func convert_json_card_stats(card: Dictionary) -> Dictionary:
	
	var c: int = 1
	for stat in preload("res://static_data/general/type_stats.tres").types_to_stat[card.type]:
		var numbered_stat: String = "stat%s" % str(c)
		if stat != null:
			card[stat] = card[numbered_stat]
			
		card.erase(numbered_stat)
		c += 1
		
	return {}

