class_name MapNodeGD extends FofGD

#region Globals
var map_location: MapLocation
var link_models: Array
var links: Array
var Model: Node3D

const PROGRESS_OFFSET: float = 3
const LANE_OFFSET: float = 4
const CENTER_PROGRESS_OFFSET: float = -15
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
	Model = info.model.instantiate()
	add_child(Model)
	setPosition(map_locations)
#endregion

#region Links
func onCreateLinks(map_location_to_node: Dictionary) -> void:
	for link in links:
		var MapNodeLink: Node3D = load(info.MAP_NODE_LINK_PATH).instantiate()
		link_models.append(MapNodeLink)
		add_child(MapNodeLink)
		
		var vector: Vector3 = map_location_to_node[link].position - map_location_to_node[map_location].position
		MapNodeLink.setInfo(vector)
#endregion
		
#region Selected
func onSelected() -> void:
	Model.visible = false
	for link_model in link_models: link_model.onMapNodeSelected()
	
func onDeselected() -> void:
	Model.visible = true
#endregion

#region Setters
func setPosition(map_locations: Array) -> void:
	var pos := Vector3((map_location.progress * PROGRESS_OFFSET) + CENTER_PROGRESS_OFFSET, 0.3, 0)
	var lanes: Array = map_locations.filter(func(x: MapLocation): return x.progress == map_location.progress)\
	.map(func(x: MapLocation): return x.lane)
	var direction: int = 0
	
	match lanes.size():
		2: direction = -1 if lanes.max() == 1 else 1
		4: direction = -1 if lanes.max() == 2 else 1
	
	pos.z = (map_location.lane + (direction * 0.5)) * LANE_OFFSET
	position = pos
#endregion
