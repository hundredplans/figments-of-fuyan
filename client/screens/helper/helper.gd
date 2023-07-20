extends Node
const static_data: String = "res://static_data/"
var static_data_length: int = static_data.length()
var uid: int = 1

var clan_convert_path: String = "res://static_data/cards/card_clan_to_full_clan.json"
@onready var clan_convert: Dictionary = Helper.load_json(clan_convert_path)
var card_back_convert_path: String = "res://static_data/cards/card_back_convert.json"
@onready var card_back_convert: Dictionary = Helper.load_json(card_back_convert_path)
var card_text_data_path: String = "res://static_data/cards/card_text_data.json"
@onready var card_text_data: Dictionary = Helper.load_json(card_text_data_path)
var caps_keywords_path: String = "res://static_data/cards/caps_keywords.json"
@onready var caps_keywords: Dictionary = Helper.load_json(caps_keywords_path)
var aliased_cards_path: String = "res://static_data/cards/aliased_art_max.json"
@onready var aliased_cards: Dictionary = Helper.load_json(aliased_cards_path)

func write_json(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file = null

func load_json(path: String) -> Dictionary:
	
	var dict: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	for key in dict:
		# Converts arrays into vector3s
		if typeof(dict[key]) == TYPE_ARRAY and dict[key].size() == 3:
			for child in dict[key]:
				if typeof(child) != TYPE_FLOAT:
					continue
			dict[key] = Vector3(dict[key][0], dict[key][1], dict[key][2])
	return dict
	
func create_max_card(card: Dictionary):
	var max_card: Node3D = load("res://assets/max_mini/max/max_card.tscn").instantiate()
	max_card.create_card(card, clan_convert, card_back_convert, card_text_data, caps_keywords, aliased_cards, uid)
	uid += 1
	return max_card
