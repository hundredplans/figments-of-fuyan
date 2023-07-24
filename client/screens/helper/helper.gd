extends Node

var compile: bool = false
var uid: int = 1
const max_lines: Dictionary = {
	"Text": 5, 
	"Clan": 1,
	"Name": 1,
}

const outline_size: int = 11
const keyword_color := "BISQUE"
const unique_ability_color := "CHARTREUSE"
const card_reference_color := "HONEYDEW"

var card_preload_path: String = "res://static_data/cards/card_preload.json"
@onready var card_preload: Dictionary = Helper.load_json(card_preload_path)
var card_back_convert_path: String = "res://static_data/cards/card_back_convert.json"
@onready var card_back_convert: Dictionary = Helper.load_json(card_back_convert_path)
var caps_keywords_path: String = "res://static_data/cards/caps_keywords.json"
@onready var caps_keywords: Dictionary = Helper.load_json(caps_keywords_path)
var aliased_cards_path: String = "res://static_data/cards/aliased_art_max.json"
@onready var aliased_cards: Dictionary = Helper.load_json(aliased_cards_path)
var unique_abilities_path: String = "res://static_data/cards/unique_abilities.json"
@onready var unique_abilities: Dictionary = Helper.load_json(unique_abilities_path)

func write_file(path: String, text: String) -> void:
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
	max_card.create_card(card, card_back_convert, aliased_cards, card_preload, uid)
	uid += 1
	return max_card

func read_contents(filepath: String) -> String:
	var file := FileAccess.open(filepath, FileAccess.READ)
	return file.get_as_text()

func upgrade_ability_text(text: String):
	
	for keyword in caps_keywords.keywords:
		var regex := RegEx.create_from_string(keyword)
		var contents: Array = regex.search_all(text)
		for m in contents:
			var content: String = m.get_string()
			text = text.replace(content, "[color=%s][b][outline_size=%s]%s[/outline_size][/b][/color]" % [keyword_color, outline_size, content.capitalize()])
			
	for i in unique_abilities:
		text = text.replace(i, "[color=%s][b][outline_size=%s]%s[/outline_size][/b][/color]" % [unique_ability_color, outline_size, i])
		
	return text
	
func upgrade_card_references(text: String, _cid: int, all_cards: Dictionary):
	var c: Dictionary = {}
	for cid in all_cards:
		if text.contains(all_cards[cid].name):
			text = text.replace(all_cards[cid].name, "[color=%s][b][outline_size=%s]%s[/outline_size][/b][/color]" % [card_reference_color, outline_size, all_cards[cid].name])
			if compile:
				match c.has(all_cards[cid].name):
					false: c.merge({all_cards[cid].name: [_cid]})
					true: c[all_cards[cid].name].append(_cid)
	
	if compile:
		var refs: Dictionary = get_tree().get_root().get_node("all_cards_to_owned").all_cards_references
		for key in c:
			match refs.has(key):
				false: refs.merge({key: c[key]})
				true: refs[key] += c[key]
	
	return text
		
func change_text_size(labels: Array, cid: int):
	var restart: bool = false
	for lab in labels:
		if lab.get_line_count() > max_lines[lab.name]:
			lab["theme_override_font_sizes/normal_font_size"] -= 1
			lab["theme_override_font_sizes/bold_font_size"] -= 1
			restart = true
			
	if restart: call_deferred("change_text_size", labels, cid)
	elif compile:
		var compiled_size: Dictionary = {
			"clan_size": labels[0]["theme_override_font_sizes/normal_font_size"],
			"text_size": labels[1]["theme_override_font_sizes/normal_font_size"],
			"name_size": labels[2]["theme_override_font_sizes/normal_font_size"],
		}
		get_tree().get_root().get_node("all_cards_to_owned").on_card_size_compiled(compiled_size, cid)
	
func set_default_tags(text: String):
	return "[center][outline_color=black][outline_size=8]%s[/outline_size][/outline_color][/center]" % text
