extends Node
var current_deck_selected_path: String = "res://mobile_data/current_selected/current_deck_selected.json"
var current_hero_selected_path: String = "res://mobile_data/current_selected/current_hero_selected.json"

@onready var owned_heroes: Dictionary = Helper.load_json("res://mobile_data/owned_heroes.json")
var current_hero_selected: String
var current_deck_selected: String
var deck_info: Dictionary

func _ready() -> void:
	current_hero_selected = Helper.load_json(current_hero_selected_path).hero
	validate_current_hero_selected()
	
func set_current_hero_selected(new_hero: String) -> void:
	
	match current_hero_selected:
		new_hero: current_hero_selected = ""
		_: current_hero_selected = new_hero
	validate_current_hero_selected()
	
func validate_current_hero_selected():
	if current_hero_selected not in owned_heroes.heroes: current_hero_selected = ""
	Helper.write_json(current_hero_selected_path, "{\"hero\": \"%s\"}" % current_hero_selected)
