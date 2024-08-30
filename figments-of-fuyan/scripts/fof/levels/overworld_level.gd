class_name OverworldLevelGD extends LevelGD

var area_info: AreaInfo
var map_location: MapLocation
var map_nodes_data: Array[SavedDataMapNode]

func onSave() -> SavedData:
	return SavedDataOverworldLevel.new(info.id, map_location, map_nodes_data)

func onLoadData(data: SavedData) -> void:
	super(data)
	map_location = data.map_location
	map_nodes_data = data.map_nodes_data
	area_info = Helper.getResourcesRecursiveID(AreaInfo, map_location.area)
	
	for _data in info.data: SavedData.onLoadModel(_data, self)
	add_to_group("OverworldLevelGD")
	
func onGenerateBaseMapNodes(Card: CardGD) -> void:
	if map_nodes_data.is_empty():
		Helper.getResourcesRecursiveID(WorldDatastore, map_location.world)\
		.onGenerateBaseMapNodes(self, map_location, Card)
		return
		
	for saved_data in map_nodes_data: SavedData.onLoadModel(saved_data, self)
