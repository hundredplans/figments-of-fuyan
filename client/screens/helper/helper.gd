extends Node
const static_data: String = "res://static_data/"
var static_data_length: int = static_data.length()

func load_json(path: String) -> Dictionary:
	
	if path.length() > static_data_length and path.substr(0, static_data_length) == static_data:
		var dict: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		for key in dict:
			# Converts arrays into vector3s
			if dict[key].size() == 3 and typeof(dict[key]) == TYPE_ARRAY:
				for child in dict[key]:
					if typeof(child) != TYPE_FLOAT:
						continue
				dict[key] = Vector3(dict[key][0], dict[key][1], dict[key][2])
		return dict
		
	printerr("Your path isn't valid!")
	return {}
