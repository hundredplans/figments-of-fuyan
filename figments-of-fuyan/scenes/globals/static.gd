class_name StaticHelper
extends Resource

static func getChildrenRecursive(node: Node, children := []) -> Array:
	children.append(node)
	for child in node.get_children():
		children = getChildrenRecursive(child, children)
	return children

static func getResourcesRecursive(DIR_PATH: String, type: GDScript) -> Array:
	var files: Array = getFilesRecursive(DIR_PATH)
	files = files.filter(func(x: String): return x.ends_with(".tres"))
	files = files.map(func(x: String): return load(DIR_PATH + x))
	return files.filter(func(x: Resource): return is_instance_of(x, type))
	
static func getResourcesRecursiveID(DIR_PATH: String, type: GDScript, id: int) -> Variant:
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

static func onAutoIncrementID(type: Variant, _id: int) -> int:
	if Engine.is_editor_hint():
		var id: int = _id
		var resources: Array = getResourcesRecursive(type.getInfoPath(), type)
		resources.sort_custom(func(x: Resource, y: Resource): return x.id < y.id)
		
		id = getNonConsecutive(resources)
		if id == -1: return resources.size() + 1
		return id + 1
	return _id

static func getNonConsecutive(arr: Array) -> int:
	var i: int = 1
	for x in arr:
		if i < arr.size() and arr[i].id - arr[i-1].id != 1:
			return arr[i - 1].id
		i += 1
	return -1
