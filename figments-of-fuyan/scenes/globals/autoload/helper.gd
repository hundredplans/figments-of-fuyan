extends Node

var admin: bool = true
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

func getResourcesRecursive(type: GDScript, DIR_PATH: String = type.getInfoPath()) -> Array:
	var files: Array = getFilesRecursive(DIR_PATH)
	files = files.map(func(x: String): return load(x))
	return files.filter(func(x: Resource): return is_instance_of(x, type))
	
func getResourcesRecursiveID(type: GDScript, id: int, DIR_PATH: String = type.getInfoPath()) -> Variant:
	var arr: Array = getResourcesRecursive(type, DIR_PATH)
	for info in arr:
		if info.id == id: return info
	return null
	
func getFilesRecursive(DIR_PATH: String, contents := []) -> Array:
	contents += Array(DirAccess.get_files_at(DIR_PATH)).map(func(x: String): return DIR_PATH + "/" + x)
	for dir in DirAccess.get_directories_at(DIR_PATH):
		contents = getFilesRecursive(DIR_PATH + "/" + dir, contents)
	return contents

func onAutoIncrementID(type: Variant, _id: int) -> int:
	if Engine.is_editor_hint():
		var id: int = _id
		var resources: Array = getResourcesRecursive(type.getInfoPath(), type)
		resources.sort_custom(func(x: Resource, y: Resource): return x.id < y.id)
		
		id = getNonConsecutive(resources)
		if id == -1: return resources.size() + 1
		return id + 1
	return _id

func getNonConsecutive(arr: Array) -> int:
	var i: int = 1
	for x in arr:
		if i < arr.size() and arr[i].id - arr[i-1].id != 1:
			return arr[i - 1].id
		i += 1
	return -1
	
func getNodeTypeRecursive(parent: Node3D, script_type: Variant):
	return Helper.getChildrenRecursive(parent).filter(func(x: Node): return is_instance_of(x, script_type))

var replacement_letters: Array = ["X", "Y", "Z"]
func getDescription(text: String, array: Array) -> String:
	for i in range(array.size()):
		text = text.replacen("[" + replacement_letters[i] + "]", str(array[i]))
	return text
