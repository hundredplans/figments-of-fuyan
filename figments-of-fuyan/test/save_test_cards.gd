extends Node

func _ready() -> void:
	var frederic: CardInfo = Helper.getFofInfoID(CardInfo, 1)
	const DIR_PATH: String = "res://resources/fof/cards/"
	for file_name in DirAccess.get_files_at(DIR_PATH):
		var info: CardInfo = load(DIR_PATH + file_name)
		if info.id in range(56, 78):
			info.model = frederic.model
			info.points = frederic.points
			info.collision_shape = frederic.collision_shape
			info.saved_data = load("res://scripts/saved_data/game_objects/saved_data_card.gd")
			info.gdscript = load("res://scripts/fof/cards/card.gd")
			
			ResourceSaver.save(info)
