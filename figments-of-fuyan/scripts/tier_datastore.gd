class_name TierDatastore extends Resource
# For each if the new value isn't set it takes the value from the previous tier

@export var description_datastore: DescriptionDatastore
	
func getDescription(use_default_values: bool = false) -> String:
	return description_datastore.getDescription(use_default_values)
