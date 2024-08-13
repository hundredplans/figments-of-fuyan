extends Node

func getChildrenRecursive(node: Node, children := []) -> Array:
	children.append(node)
	for child in node.get_children():
		children = getChildrenRecursive(child, children)
	return children

func getCollision(collider: Node, type: Variant) -> Variant:
	if collider != null:
		while (true):
			if is_instance_of(collider, type): return collider
			else: collider = collider.get_parent()
	return null
		
func getRayParentMultiple(_collider: StaticBody3D, _type_array: Array) -> Variant:
	return null

func getResourcesRecursive(DIR_PATH: String, type: Variant) -> Array:
	var files: Array = getFilesRecursive(DIR_PATH)
	files = files.filter(func(x: String): return x.ends_with(".tres"))
	files = files.map(func(x: String): return load(DIR_PATH + x))
	return files.filter(func(x: Resource): return is_instance_of(x, type))
	
func getResourcesRecursiveID(DIR_PATH: String, type: Variant, id: int) -> Variant:
	var arr: Array = getResourcesRecursive(DIR_PATH, type)
	for info in arr:
		if info.id == id: return info
	return null
	
func getFilesRecursive(DIR_PATH: String) -> Array:
	var files: Array = []
	var dir = DirAccess.open(DIR_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir(): files.append(file_name)
			file_name = dir.get_next()
	return files
