class_name StaticHelper
extends Resource

static func getResourcesRecursive(DIR_PATH: String, type: Variant) -> Array:
	var files: Array = getFilesRecursive(DIR_PATH)
	files = files.filter(func(x: String): return x.ends_with(".tres"))
	files = files.map(func(x: String): return load(DIR_PATH + x))
	return files.filter(func(x: Resource): return is_instance_of(x, type))
	
static func getResourcesRecursiveID(DIR_PATH: String, type: Variant, id: int) -> Variant:
	var arr: Array = getResourcesRecursive(DIR_PATH, type)
	for info in arr:
		if info.id == id: return info
	return null

static func getFilesRecursive(DIR_PATH: String) -> Array:
	var files: Array = []
	var dir = DirAccess.open(DIR_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir(): files.append(file_name)
			file_name = dir.get_next()
	return files
