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

static func onAutoIncrementID(DIR_PATH: String, type: Variant, _id: int) -> int:
	if Engine.is_editor_hint():
		var id: int = _id
		var resources: Array = getResourcesRecursive(DIR_PATH, type)
		resources.sort_custom(func(x: GameObjectInfoGD, y: GameObjectInfoGD): return x.id < y.id)
		
		id = getNonConsecutive(resources)
		if id == -1: return resources.size() + 1
		return id + 1
	return _id

static func getNonConsecutive(arr: Array) -> int:
	var i: int = 1
	for x in arr:
		if i < arr.size() and arr[i] - arr[i-1] != 1:
			return arr[i - 1]
		i += 1
	return -1
