class_name SaveFile extends Resource

@export var save_slot: int
@export var map_location: MapLocation
@export var map_nodes_data: Array[SavedDataMapNode]
@export var seed: int

func _init() -> void:
	save_slot = getSaveSlotCount() + 1
	map_location.world = 1
	map_location.area = getRandomAreaID()
	seed = randi()
	Random.setSeed(seed)
	ResourceSaver.save(self, INFO_PATH + str(save_slot) + ".tres")

#region Generator
func onGenerateBaseMapNodes(parent: Control) -> void:
	if map_nodes_data == null:
		map_nodes_data = []
		Helper.getResourcesRecursiveID(WorldInfo, map_location.world)\
		.onGenerateBaseMapNodes(parent, map_location, [10])
		for map_node in parent.get_tree().get_nodes_in_group("MapNodes"):
			map_nodes_data.append(map_node.onSave())
	else: for saved_data in map_nodes_data: saved_data.onLoad(parent)
#endregion

#region Save Slots
static var INFO_PATH: String = "user://save/save_files/"
static func getSaveSlotCount() -> int:
	return Helper.getResourcesRecursive(SaveFile).size()
#endregion

func getRandomAreaID() -> int:
	return 1
