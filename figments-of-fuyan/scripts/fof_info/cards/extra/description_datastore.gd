class_name DescriptionDatastore extends Resource

@export_multiline var description: String
@export var default_values: Array[int] # X, Y, Z etc

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values and !default_values.is_empty():
		return Helper.getDescription(description, default_values)
	return description

func getDefaultValue(index: int) -> int:
	return default_values[index]
