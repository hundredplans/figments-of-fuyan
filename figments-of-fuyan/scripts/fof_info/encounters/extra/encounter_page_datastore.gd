class_name EncounterPageDatastore extends Resource

@export var title: String
@export_multiline var description: String
@export var options: Array[EncounterOptionDatastore]

func getOptionByName(option_name: String) -> EncounterOptionDatastore:
	for option in options:
		if option.name == option_name: return option
	assert(false) # Page doesn't exist
	return null
	
