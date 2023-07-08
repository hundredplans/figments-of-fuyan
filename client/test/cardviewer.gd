extends Node3D
var all_cards = Helper.load_json("res://static_data/cards/all_cards.json")
var clan_convert_path: String = "res://static_data/cards/card_clan_to_full_clan.json"
@onready var clan_convert: Dictionary = Helper.load_json(clan_convert_path)
var card_back_convert: Dictionary = {
	"1": "res://assets/max_mini/max/card_back/blue/card_back.blend"
}

func _ready(): 
	var ypos: int = 0
	var xpos: int = 0
	for dictcard in all_cards.values():
		var card = load("res://assets/max_mini/max/max_card.tscn").instantiate()
		card.position.z = -2.2
		card.position.x = xpos
		card.position = Vector3(xpos, ypos, -2.2)
		card.create_card(dictcard, clan_convert, card_back_convert, 1)
		add_child(card)
		xpos += 4
		if xpos % 80 == 0:
			ypos += 4
			xpos = 0
