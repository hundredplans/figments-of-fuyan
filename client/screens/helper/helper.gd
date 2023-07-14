extends Node
const static_data: String = "res://static_data/"
var static_data_length: int = static_data.length()
var uid: int = 1

var clan_convert_path: String = "res://static_data/cards/card_clan_to_full_clan.json"
@onready var clan_convert: Dictionary = Helper.load_json(clan_convert_path)
var card_back_convert_path: String = "res://static_data/cards/card_back_convert.json"
@onready var card_back_convert: Dictionary = Helper.load_json(card_back_convert_path)

func load_json(path: String) -> Dictionary:
	
	if path.length() > static_data_length and path.substr(0, static_data_length) == static_data:
		var dict: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		for key in dict:
			# Converts arrays into vector3s
			if typeof(dict[key]) == TYPE_ARRAY and dict[key].size() == 3:
				for child in dict[key]:
					if typeof(child) != TYPE_FLOAT:
						continue
				dict[key] = Vector3(dict[key][0], dict[key][1], dict[key][2])
		return dict
		
	printerr("Your path isn't valid!")
	return {}
	
func create_max_card(card: Dictionary):
	var max_card: Node3D = load("res://assets/max_mini/max/max_card.tscn").instantiate()
	max_card.create_card(card, clan_convert, card_back_convert, uid)
	uid += 1
	return max_card
