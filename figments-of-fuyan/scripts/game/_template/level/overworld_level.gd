class_name OverworldLevelGD extends LevelGD

var area_info: AreaInfoGD
var map_location: MapLocation
var map_nodes_data: Array[SavedDataMapNode]

func onLoad(data: SavedData, parent: Node3D) -> LevelGD:
	super(data, parent)
	map_location = data.map_location
	map_nodes_data = data.map_nodes_data
	area_info = Helper.getResourcesRecursiveID(AreaInfoGD, map_location.area)
	
	for _data in info.data:
		_data.onLoadModel(self)
	return self
	
func onSave() -> SavedDataLevel:
	return SavedDataOverworldLevel.new(info.id, map_location, map_nodes_data)
	
func onClear() -> void:
	queue_free()
	
func onGenerateBaseMapNodes(Unit: UnitGD) -> void:
	if map_nodes_data.is_empty():
		Helper.getResourcesRecursiveID(WorldInfo, map_location.world)\
		.onGenerateBaseMapNodes(self, map_location, Unit)
		return
		
	for saved_data in map_nodes_data:
		saved_data.onLoadModel(self)
