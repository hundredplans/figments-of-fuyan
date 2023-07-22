extends Node
const static_data: String = "res://static_data/"
var static_data_length: int = static_data.length()
var uid: int = 1

var regex_parsers: Array
var clan_convert_path: String = "res://static_data/cards/card_clan_to_full_clan.json"
@onready var clan_convert: Dictionary = Helper.load_json(clan_convert_path)
var card_back_convert_path: String = "res://static_data/cards/card_back_convert.json"
@onready var card_back_convert: Dictionary = Helper.load_json(card_back_convert_path)
var caps_keywords_path: String = "res://static_data/cards/caps_keywords.json"
@onready var caps_keywords: Dictionary = Helper.load_json(caps_keywords_path)
var aliased_cards_path: String = "res://static_data/cards/aliased_art_max.json"
@onready var aliased_cards: Dictionary = Helper.load_json(aliased_cards_path)
var unique_abilities_path: String = "res://static_data/cards/unique_abilities.json"
@onready var unique_abilities: Dictionary = Helper.load_json(unique_abilities_path)

func write_json(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file = null

func load_json(path: String) -> Dictionary:
	
	var dict: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	for key in dict:
		# Converts arrays into vector3s
		if typeof(dict[key]) == TYPE_ARRAY and dict[key].size() == 3:
			if dict[key].all(func(x): return typeof(x) == TYPE_FLOAT):
				dict[key] = Vector3(dict[key][0], dict[key][1], dict[key][2])
				
	return dict
	
func create_max_card(card: Dictionary):
	var max_card: Node3D = load("res://assets/max_mini/max/max_card.tscn").instantiate()
	max_card.create_card(card, clan_convert, card_back_convert, aliased_cards, uid)
	uid += 1
	return max_card

func read_contents(filepath: String) -> String:
	var file := FileAccess.open(filepath, FileAccess.READ)
	return file.get_as_text()

func upgrade_ability_text(text: String):
	var regex := RegEx.create_from_string("PLUNDER?S")
	var res = regex.search(text)
	if res:
		print(res.get_string())
#	var l: int = text.length()
#	for type in caps_keywords:
#		var extend: bool = false
#		if type == "extend_keywords": extend = true
#		for ability in caps_keywords[type]:
#			for sub in text.split(ability, true):
#				print(sub)
#				var i: int = 1
#				for c in text.substr(sub.length()):
#					print(c)
#					if c == " " or i == l:
#						if !extend:
#							var supersub: String = sub + text.substr()
#							text = text.replacen(supersub, "[b]%s[/b]" % supersub.capitalize())
#						else: extend = false
#					i += 1
	return text
	
func set_default_tags(text: String):
	return "[center][outline_color=black][outline_size=8]%s[/outline_size][/outline_color][/center]" % text
