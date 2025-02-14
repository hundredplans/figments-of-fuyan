extends Node

func _ready() -> void:
	var model_card: CardInfo = Helper.getFofInfoID(CardInfo, 3)
	const DIR_PATH: String = "res://resources/fof/cards/"
	var brute: ArchetypeInfo = load("res://resources/fof/archetypes/brute.tres")
	
	for file_name in DirAccess.get_files_at(DIR_PATH):
		var info: CardInfo = load(DIR_PATH + file_name)
		if info.id in range(30, 56):
			info.model = model_card.model
			info.points = model_card.points
			info.collision_shape = model_card.collision_shape
			info.top = model_card.top
			info.eye = model_card.eye
			info.stat = model_card.stat
			info.saved_data = load("res://scripts/saved_data/game_objects/saved_data_card.gd")
			info.gdscript = load("res://scripts/fof/cards/card.gd")
			info.archetype = brute
			
			ResourceSaver.save(info)
