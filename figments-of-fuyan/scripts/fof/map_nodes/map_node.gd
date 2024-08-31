class_name MapNodeGD extends FofGD

#region Globals
var map_location: MapLocation
var links: Array
var Model: Node3D
#endregion

#region Save / Load
func onSave() -> SavedDataMapNode:
	return SavedDataMapNode.new(info.id, map_location, links)

func onLoadData(data: SavedData) -> void:
	super(data)
	map_location = data.map_location
	links = data.links
	add_to_group("MapNodesGD")
	
func onCreateModel(map_locations: Array) -> void:
	Model = load(info.MAP_NODE_MODEL_PATH).instantiate()
	add_child(Model)
	Model.setInfo(self, map_locations, info.model)
	
func onCreateLinks(map_location_to_node: Dictionary) -> void:
	Model.onCreateLinks(links, map_location, map_location_to_node)
	
func getPosition() -> Vector3:
	return Model.position
#endregion
