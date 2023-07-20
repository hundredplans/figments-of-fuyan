extends Node
@onready var owned_heroes: Dictionary = Helper.load_json("res://server_data/owned_heroes.json")
var current_hero_selected: String
var deck_info: Dictionary

func _ready() -> void:
	current_hero_selected = Helper.load_json("res://static_data/deck_manager/current_hero_selected.json").hero
	validate_current_hero_selected()
	load_decks()
	
func set_current_hero_selected(new_hero: String) -> void:
	
	match current_hero_selected:
		new_hero: current_hero_selected = ""
		_: current_hero_selected = new_hero
	validate_current_hero_selected()
	
func validate_current_hero_selected():
	if current_hero_selected not in owned_heroes.heroes: current_hero_selected = ""
	Helper.write_json("res://static_data/deck_manager/current_hero_selected.json", "{\"hero\": \"%s\"}" % current_hero_selected)

func load_decks() -> void:
	pass
