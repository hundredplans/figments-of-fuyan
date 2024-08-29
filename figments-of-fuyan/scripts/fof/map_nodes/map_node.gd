class_name MapNodeGD extends FofGD

#region Globals
var map_location: MapLocation
var links: Array[MapLocation]
#endregion

#region Save / Load
func onSave() -> SavedDataMapNode:
	return SavedDataMapNode.new(info.id, map_location, links)

func onLoadData(data: SavedData) -> void:
	super(data)
	map_location = data.map_location
	links = data.links
	
	var model: Node3D = info.model.instantiate()
	add_child(model)
	position = getPositionFromMapLocation(map_location)
	
	add_to_group("MapNodeGD")
#endregion

#region Transformers
func getPositionFromMapLocation(map_location: MapLocation) -> Vector3:
	return Vector3(map_location.progress * 3, 0.6, map_location.lane * 2)
#endregion
