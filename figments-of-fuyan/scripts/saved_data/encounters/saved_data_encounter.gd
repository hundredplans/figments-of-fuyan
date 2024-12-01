class_name SavedDataEncounter extends SavedData

@export var ability_save: Dictionary
@export var loaded_page_name: String # Default is StartPage

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _ability_save: Dictionary = {}, _loaded_page_name: String = "StartPage") -> void:
	super(_id, _first_init, _public_id)
	ability_save = _ability_save
	loaded_page_name = _loaded_page_name

func getInfoType() -> GDScript: return EncounterInfo
