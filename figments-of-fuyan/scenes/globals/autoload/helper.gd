extends Node

func getAdmin() -> bool: return false
#region Resources
var GDSCRIPT_TYPES: Array = [AreaInfo, LevelInfo, PalmLevelInfo, \
	CardInfo, ChampionCardInfo, BoonInfo, ToolInfo, MapNodeInfo, SaveFileInfo, EncounterInfo, MapEffectInfo,\
	TileObjectInfo, TileInfo, ObjectInfo, GameObjectInfo, TraitInfo, StatusEffectInfo]
	
var fof_info_dict: Dictionary = {}
func _ready() -> void:
	for type in GDSCRIPT_TYPES:
		fof_info_dict[type] = {}
		if type not in [TileInfo, ObjectInfo]:
			var DIR_PATH: String = type.getInfoPath()
			var fof_info_array: Array = getFilesRecursive(DIR_PATH).map(func(x: String): return load(x)).filter(func(x: FofInfo): return is_instance_of(x, type))
			
			if type == CardInfo:
				var ALT_DIR_PATH: String = "res://test/test_cards/"
				fof_info_array += getFilesRecursive(ALT_DIR_PATH).map(func(x: String): return load(x))
					
			for fof_info in fof_info_array:
				fof_info_dict[type][fof_info.id] = fof_info 
		else: fof_info_dict[type] = fof_info_dict[TileObjectInfo]
		
func getFofInfoArray(type: GDScript) -> Array:
	var arr: Array = fof_info_dict[type].values()
	arr.sort_custom(func(x: FofInfo, y: FofInfo): return x.id < y.id)
	return arr
	
func getFofInfoID(type: GDScript, id: int) -> FofInfo:
	return fof_info_dict[type][id]
#endregion

func getChildrenRecursive(node: Node, children := []) -> Array:
	children.append(node)
	for child in node.get_children():
		children = getChildrenRecursive(child, children)
	return children

const MOUSE_RAY_LENGTH: int = 5000
func setCameraRay(Ray: RayCast3D, Camera: Camera3D) -> void:
	Ray.position = Camera.position
	Ray.target_position = Camera.project_ray_normal(Ray.get_viewport().get_mouse_position()) * MOUSE_RAY_LENGTH
	Ray.force_raycast_update()

func getCollision(collider: Node, type: Variant) -> Variant:
	if collider != null:
		while (true):
			if is_instance_of(collider, type): return collider
			else: collider = collider.get_parent()
	return null
		
func getRayParentMultiple(_collider: StaticBody3D, _type_array: Array) -> Variant:
	return null
	
func getFilesRecursive(DIR_PATH: String, contents := []) -> Array:
	contents += Array(DirAccess.get_files_at(DIR_PATH)).map(func(x: String): return DIR_PATH + "/" + x)
	for dir in DirAccess.get_directories_at(DIR_PATH):
		contents = getFilesRecursive(DIR_PATH + "/" + dir, contents)
	return contents
	
func getNodeTypeRecursive(parent: Node3D, script_type: Variant):
	return getChildrenRecursive(parent).filter(func(x: Node): return is_instance_of(x, script_type))

const replacement_letters: Array = ["X", "Y", "Z"]
func getDescription(text: String, array: Array) -> String:
	for i in range(array.size()):
		text = text.replacen("[" + replacement_letters[i] + "]", str(array[i]))
	return text
