class_name StaticHelper
extends Resource

static func getChildrenRecursive(node: Node, children := []) -> Array:
	children.append(node)
	for child in node.get_children():
		children = getChildrenRecursive(child, children)
	return children

static func getResourcesRecursive(DIR_PATH: String, type: GDScript) -> Array:
	var files: Array = getFilesRecursive(DIR_PATH)
	files = files.map(func(x: String): return load(x))
	return files.filter(func(x: Resource): return is_instance_of(x, type))
	
static func getResourcesRecursiveID(DIR_PATH: String, type: GDScript, id: int) -> Variant:
	var arr: Array = getResourcesRecursive(DIR_PATH, type)
	for info in arr:
		if info.id == id: return info
	return null

static func getFilesRecursive(DIR_PATH: String, contents := []) -> Array:
	contents += Array(DirAccess.get_files_at(DIR_PATH)).map(func(x: String): return DIR_PATH + "/" + x)
	for dir in DirAccess.get_directories_at(DIR_PATH):
		contents = getFilesRecursive(DIR_PATH + "/" + dir, contents)
	return contents

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
