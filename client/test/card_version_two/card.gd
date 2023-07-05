extends Node3D

func _ready():
	$art/art_max.set_position(Vector3(0, 0.04, 0.0004))
	
func on_create_card(card_back_path: String, card: Dictionary):
	load_card_back(card_back_path)
	load_card_stats(card)
	
func load_card_back(card_back_path: String):
	var card_back: Node3D = load(card_back_path).instantiate()
	card_back.set_name("card_back")
	add_child(card_back)

func load_card_stats(card):
	for stat in []:
		pass
