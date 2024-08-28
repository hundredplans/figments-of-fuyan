extends Node

func getChildrenRecursive(node: Node, children := []) -> Array:
	children.append(node)
	for child in node.get_children():
		children = getChildrenRecursive(child, children)
	return children

const MOUSE_RAY_LENGTH: int = 5000
func setCameraRay(Ray: RayCast3D, Camera: Camera3D) -> void:
	Ray.position = Camera.position
	Ray.target_position = Camera.project_ray_normal(get_viewport().get_mouse_position()) * MOUSE_RAY_LENGTH
	Ray.force_raycast_update()

func getCollision(collider: Node, type: Variant) -> Variant:
	if collider != null:
		while (true):
			if is_instance_of(collider, type): return collider
			else: collider = collider.get_parent()
	return null
		
func getRayParentMultiple(_collider: StaticBody3D, _type_array: Array) -> Variant:
	return null

func getResourcesRecursive(type: Variant, DIR_PATH: String = type.INFO_PATH) -> Array:
	var files: Array = getFilesRecursive(DIR_PATH)
	files = files.filter(func(x: String): return x.ends_with(".tres"))
	files = files.map(func(x: String): return load(DIR_PATH + x))
	return files.filter(func(x: Resource): return is_instance_of(x, type))
	
func getResourcesRecursiveID(type: Variant, id: int, DIR_PATH: String = type.INFO_PATH) -> Variant:
	var arr: Array = getResourcesRecursive(type, DIR_PATH)
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
