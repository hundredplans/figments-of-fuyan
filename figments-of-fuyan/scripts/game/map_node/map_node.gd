class_name MapNode extends Node3D

#region Globals
var info: MapNodeInfoGD
var map_location: MapLocation
var links: Array[MapLocation]
#endregion

#region Save / Load / Clear
func onSave() -> SavedDataMapNode:
	return SavedDataMapNode.new(info.id, map_location, links)

func onLoad(data: SavedDataMapNode, parent: Node3D) -> void:
	info = data.getBaseInfo()
	map_location = data.map_location
	links = data.links
	parent.add_child(self)
	
	var model: Node3D = info.model.instantiate()
	add_child(model)
	position = getPositionFromMapLocation(data.map_location)
	
func onClear() -> void:
	queue_free()
#endregion

#region Transformers
func getPositionFromMapLocation(map_location: MapLocation) -> Vector3:
	return Vector3(map_location.progress * 3, 0.6, map_location.lane * 2)
#endregion
