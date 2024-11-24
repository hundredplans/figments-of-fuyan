extends Node

func _ready() -> void:
	var quentin: CardInfo = Helper.getFofInfoID(CardInfo, 3)
	const DIR_PATH: String = "res://test/test_cards/"
	for file_name in DirAccess.get_files_at(DIR_PATH):
		var info: CardInfo = load(DIR_PATH + file_name)
		info.id -= 470
		info.saved_data = load("res://scripts/saved_data/game_objects/saved_data_card.gd")
		info.model = quentin.model
		info.points = quentin.points
		info.collision_shape = quentin.collision_shape
		
		ResourceSaver.save(info, "res://resources/fof/cards/" + file_name)
