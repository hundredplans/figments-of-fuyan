extends Node

var port: int = 8712
var ip: String = "79.97.147.157"
var network := ENetMultiplayerPeer.new()

func _ready():
	on_connect_to_lobby()

func on_connect_to_lobby():
	network.create_client(ip, port)
	multiplayer.multiplayer_peer = network
	multiplayer.connect("peer_connected", func(id): get_node("/root/Main").on_lobby_connected(id))
