extends Node

# 2nd property in owned_cards is the skin
var all_cards_references: Dictionary = {}
var all_texts: Dictionary = {}
var current_compiled_cards: int = 0

var all_cards_path: String = "res://static_data/cards/all_cards_unsorted.json"
var card_references_path: String = "res://static_data/cards/card_references.json"
var card_property_converter_path: String = "res://static_data/cards/card_property_converter.json"
var caps_keywords_path: String = "res://static_data/cards/caps_keywords.json" 
var clan_convert_path: String = "res://static_data/cards/card_clan_to_full_clan.json"
var card_preload_path: String = "res://static_data/cards/card_preload.json"
@onready var converter: Dictionary = Helper.load_json(card_property_converter_path)
@onready var caps_keywords: Dictionary = Helper.load_json(caps_keywords_path)
@onready var clan_convert: Dictionary = Helper.load_json(clan_convert_path)

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
			"text":
				new_card.merge({stat: card[stat]}); has_text = true
			_: new_card.merge({stat: card[stat]})
			
	if !has_text: new_card.merge({"text": ""})
	return new_card
func _ready():
	var all_cards: Dictionary = convert_to_sorted_cards()
	convert_to_owned_cards(all_cards)
	convert_to_text_parsed(all_cards)

func convert_to_text_parsed(all_cards: Dictionary):
	Helper.compile = true
	for card in all_cards.values():
		var maxcard: Node3D = Helper.create_max_card(card)
		add_child(maxcard)
		
		maxcard.get_node("TextViewport/Text/Text").text = Helper.upgrade_ability_text(card.text)
		maxcard.get_node("TextViewport/Text/Text").text = Helper.upgrade_card_references(maxcard.get_node("TextViewport/Text/Text").text, card.cid, all_cards)
		var labels: Array = [
			[maxcard.get_node("TextViewport/Clan/Clan"), clan_convert[card.clan]],
			[maxcard.get_node("TextViewport/Text/Text"), maxcard.get_node("TextViewport/Text/Text").text],
			[maxcard.get_node("TextViewport/Name/Name"), String(card.name)]]
			
		for lab in labels:
			lab[0].text = Helper.set_default_tags(lab[1])
			
		Helper.call_deferred("change_text_size", labels.map(func(x: Array): return x[0]), card.cid)
		var texts: Dictionary = {
			"clan": maxcard.get_node("TextViewport/Clan/Clan").text,
			"text": maxcard.get_node("TextViewport/Text/Text").text,
			"name": maxcard.get_node("TextViewport/Name/Name").text,
		}
		all_texts.merge({str(card.cid): texts})
		
	var cf: String = "{"
	for key in all_cards_references: cf += "\n\t\"%s\": %s," % [key, all_cards_references[key]]
	cf += "\n}"
	Helper.write_file(card_references_path, cf)

func on_card_size_compiled(card_size: Dictionary, cid: int):
	current_compiled_cards += 1
	all_texts[str(cid)].merge(card_size)
	if current_compiled_cards == all_texts.size():
		var card_preload: String = "{\n"
		for t in all_texts:
			card_preload += "\t\"%s\":\n\t{\n\t\t\"name\": \"%s\",\n\t\t\"clan\": \"%s\",\n\t\t\"text\": \"%s\",\n\t\t\"name_size\": %s,\n\t\t\"clan_size\": %s,\n\t\t\"text_size\": %s,\n\t},\n\n"\
			% [t, all_texts[t].name, all_texts[t].clan, all_texts[t].text, all_texts[t].name_size, all_texts[t].clan_size, all_texts[t].text_size]
		
		card_preload += "}"
		Helper.write_file(card_preload_path, card_preload)

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
