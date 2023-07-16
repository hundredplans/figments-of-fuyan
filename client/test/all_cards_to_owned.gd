extends Node

# 2nd property in owned_cards is the skin
var all_cards_path: String = "res://static_data/cards/all_cards_unsorted.json"
var card_property_converter_path: String = "res://static_data/cards/card_property_converter.json" 
@onready var converter: Dictionary = Helper.load_json(card_property_converter_path)

func on_initialize_cards(_cards) -> Dictionary:
	var cards_as_dict: Dictionary  = {}
	for card in _cards: 
		cards_as_dict.merge({card: convert_card_properties(_cards[card])})
	
	return cards_as_dict
func convert_card_properties(card: Dictionary) -> Dictionary:
	var new_card: Dictionary = {}
	var has_text: bool = false
	for stat in card: # keys
		match stat:
			"type": new_card.merge({stat: converter.type_to_type[card[stat]]})
			"clan": new_card.merge({stat: converter.clan_to_clan[card[stat]]})
			"rarity": new_card.merge({stat: converter.rarity_to_rarity[card[stat]]})
			"stat3":
				for key in converter.type_to_stat:
					if card.type == key:
						if card.type != "ritual":
							new_card.merge({converter.type_to_stat[key]: card[stat]})
						else:
							var stats: Array = converter.type_to_stat[key]
							match typeof(card[stat]):
								TYPE_FLOAT:
									new_card.merge({stats[0]: float(card[stat])})
									new_card.merge({stats[1]: float(1)})
								TYPE_STRING:
									new_card.merge({stats[0]: float(card[stat][0])})
									new_card.merge({stats[1]: float(card[stat][2])})
						break
			"att", "hp", "energy": 
				new_card.merge({converter.stat_to_stat[stat]: card[stat]})
			"text": new_card.merge({stat: card[stat]}); has_text = true
			_: new_card.merge({stat: card[stat]})
			
	if new_card.cid == 236: print(new_card)
	if !has_text: new_card.merge({"text": ""})
	return new_card
func _ready():
	var all_cards: Dictionary = convert_to_sorted_cards()
	convert_to_owned_cards(all_cards)
func convert_to_sorted_cards():
	var all_cards: Dictionary = Helper.load_json(all_cards_path)
	var sorted_cards: Dictionary = on_initialize_cards(all_cards)
	var file := FileAccess.open("res://static_data/cards/all_cards.json", FileAccess.WRITE)
	
	file.store_string("{\n")
	for key in sorted_cards:
		file.store_string("\t\"%s\": {" % key)
		for stat in sorted_cards[key]:
			if typeof(sorted_cards[key][stat]) == TYPE_FLOAT:
				file.store_string("\n\t\t\"%s\": %s," % [stat, sorted_cards[key][stat]])
			else:
				file.store_string("\n\t\t\"%s\": \"%s\"," % [stat, sorted_cards[key][stat]])
			
		file.store_string("\n\t},\n")
	
	file.store_string("}")
	file = null
	return sorted_cards
func convert_to_owned_cards(all_cards):
	var path: String = "res://static_data/cards/owned_cards.json"
	var file = FileAccess.open(path,FileAccess.WRITE)
	var dad_dict: Dictionary = {}
	for card in all_cards:
		if all_cards[card].clan not in ["i", "e"]:
			var amount: int = match_rarity(all_cards[card].rarity)
			dad_dict.merge({card: [amount, 0, []]})
		
	file.store_string("{\n\t\"owned_cards\":{\n")
	for key in dad_dict:
		file.store_string("\t\"%s\":%s,\n" % [key, str(dad_dict[key])])
	file.store_string("\t},\n}")

	file = null
func match_rarity(rarity):
	match rarity:
		"l": return 1
		"e": return 2
		"r": return 3
		"c": return 4
		"s": return 0
	return 0
