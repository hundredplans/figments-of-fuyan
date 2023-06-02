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

var port: int = 8712
var network := ENetMultiplayerPeer.new()
var max_players: int = 64
var players: Array = []

func _ready():
	network.create_server(port, max_players)
	multiplayer.multiplayer_peer = network
	
	multiplayer.connect("peer_connected", func(id): on_peer_connected(id))
	multiplayer.connect("peer_disconnected", func(id): on_peer_disconnected(id))
func on_peer_connected(id: int) -> void:
	print("Player Connected: " + str(id))
	players.append(id)
func on_peer_disconnected(id: int) -> void:
	print("Player Disconnected: " + str(id))
	players.erase(id)
