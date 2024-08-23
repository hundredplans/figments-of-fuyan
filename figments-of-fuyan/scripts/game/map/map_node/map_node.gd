class_name MapNode extends Node2D

#region Globals
var info: MapNodeInfoGD
var map_location: MapLocation
var links: Array[MapLocation]
#endregion

#region Save / Load / Clear
func onSave() -> SavedDataMapNode:
	return SavedDataMapNode.new(info.id, map_location, links)

func onLoad(data: SavedDataMapNode, parent: Control) -> void:
	info = data.getBaseInfo()
	map_location = data.map_location
	links = data.links
	parent.add_child(self)
	
	
func onClear() -> void:
	queue_free()
#endregion
