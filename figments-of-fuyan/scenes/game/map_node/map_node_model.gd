extends Node3D

@export var MAP_NODE_LINK: PackedScene
@export var PROGRESS_OFFSET: float = 3
@export var LANE_OFFSET: float = 4

func setInfo(map_node: MapNodeGD, map_locations: Array, model: PackedScene) -> void:
	var map_location: MapLocation = map_node.map_location
	add_child(model.instantiate())
	setPosition(map_location, map_locations)

#region Setters
func setPosition(map_location: MapLocation, map_locations: Array) -> void:
	var pos := Vector3(map_location.progress * PROGRESS_OFFSET, 0.3, 0)
	var lanes: Array = map_locations.filter(func(x: MapLocation): return x.progress == map_location.progress)\
	.map(func(x: MapLocation): return x.lane)
	var direction: int = 0
	
	match lanes.size():
		2: direction = -1 if lanes.max() == 1 else 1
		4: direction = -1 if lanes.max() == 2 else 1
	
	pos.z = (map_location.lane + (direction * 0.5)) * LANE_OFFSET
	position = pos
#endregion

#region Getters
func getPositionFromMapLocation(_map_location: MapLocation) -> Vector3:
	return Vector3(_map_location.progress * 3, 0.6, _map_location.lane * 2)
#endregion

#region Links
func onCreateLinks(links: Array, map_location: MapLocation, map_location_to_node: Dictionary) -> void:
	for link in links:
		var MapNodeLink: Node3D = MAP_NODE_LINK.instantiate()
		add_child(MapNodeLink)
		MapNodeLink.setInfo(link, map_location, map_location_to_node)
#endregion
