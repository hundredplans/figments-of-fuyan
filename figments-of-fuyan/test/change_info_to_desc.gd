extends Node

func _ready() -> void:
	const DIR_PATH: String = "res://resources/fof/cards/"
	for file_name in DirAccess.get_files_at(DIR_PATH):
		var card_info: CardInfo = load(DIR_PATH + file_name)
		card_info.description = card_info.ability_text
		card_info.ascended_description = card_info.ascended_ability_text
		ResourceSaver.save(card_info)
	get_tree().quit()
