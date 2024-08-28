class_name SavedDataMapNode extends SavedData

@export var map_location: MapLocation
@export var links: Array[MapLocation]

func _init(_id: int = 0, _map_location: MapLocation = null, _links: Array[MapLocation] = []) -> void:
	super(_id)
	map_location = _map_location
	links = _links
	
func getBaseInfo() -> MapNodeInfoGD: return Helper.getResourcesRecursiveID(MapNodeInfoGD, id)

func onLoadModel(parent: Node3D) -> MapNode:
	var model = Node3D.new()
	model.script = call("getBaseInfo").gdscript
	return model
