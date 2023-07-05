extends Node

const start_map_load_name: String = "start_screen"
const start_gui_path: String = "res://screens/start_screen/start_screen_gui.tscn"

const lobby_map_name: String = "lobby_map"
const lobby_gui_path: String = "res://screens/lobby_map/lobby_map_gui.tscn"

func _ready():
	#$GameWorld.load_map(start_map_load_name)
	#$GUI.load_gui(start_gui_path)
	
	$GameWorld.add_to_back_history.connect(add_to_back_history)
	$GameWorld.change_animation_status.connect(change_animation_status)
	$GameWorld.lobby_camera_travel_main_menu_finished.connect(on_lobby_camera_travel_main_menu_finished)
	$GameWorld.lobby_camera_travel_item_finished.connect(on_lobby_camera_travel_item_finished)
	$GameWorld.lobby_camera_travel_item_started.connect(on_lobby_camera_travel_item_started)
	
	$GUI.lobby_item_selected.connect(on_lobby_item_selected)
	$GUI.exit_door_exit_game.connect(on_exit_door_exit_game)
	
	on_lobby_connected(5)
func on_lobby_connected(_id: int) -> void:
	$GUI.load_lobby_gui(lobby_gui_path)
	$GameWorld.load_lobby_map(lobby_map_name)

var all_cards_path: String = "res://static_data/all_cards.json"
var card_property_converter_path: String = "res://static_data/card_property_converter.json"
@onready var converter: Dictionary = Helper.load_json(card_property_converter_path)
@onready var all_cards: Dictionary = on_initialize_cards(Helper.load_json(all_cards_path).all_cards)

func on_initialize_cards(_cards) -> Dictionary:
	var cards_as_dict: Dictionary  = {}
	for card in _cards:
		cards_as_dict.merge(convert_card_properties(card))

	return cards_as_dict
	
func convert_card_properties(card: Dictionary) -> Dictionary:
	
	var new_card: Dictionary = {}
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
									new_card.merge({stats[0]: card[stat]})
									new_card.merge({stats[1]: 1})
								TYPE_STRING:
									new_card.merge({stats[0]: int(card[stat][0])})
									new_card.merge({stats[1]: int(card[stat][2])})
						break
			"att", "hp", "energy": 
				new_card.merge({converter.stat_to_stat[stat]: card[stat]})
			_: new_card.merge({stat: card[stat]})

	return {str(card.cid): new_card}

func on_lobby_camera_travel_item_started(item_id: int, direction: bool):
	$GUI.on_lobby_camera_travel_item_started(item_id, direction)

func add_to_back_history(item: Array):
	$GUI.add_to_back_history(item)
func change_animation_status(status: int):
	$GUI.change_animation_status(status)
func on_lobby_item_selected(item_id: int):
	$GameWorld.on_lobby_item_selected(item_id)	
func on_lobby_camera_travel_main_menu_finished():
	$GUI.on_lobby_camera_travel_main_menu_finished()
func on_lobby_camera_travel_item_finished(path: String):
	$GUI.on_lobby_camera_travel_item_finished(path)
func on_exit_door_exit_game(path: String):
	$GameWorld.on_exit_door_exit_game(path)
