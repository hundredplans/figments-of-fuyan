extends Control

@export var MinimapNodePacked: PackedScene
@export var MinimapLinkPacked: PackedScene
@export var id_to_icons: Array[IdToIcon]

@onready var NodeParent: Control = %NodeParent
@onready var Links: Node2D = %Links

const SPACING := Vector2(75, 60)

signal mouse_in_ui

func _ready() -> void:
	var data: Array = getData()
	
	data.sort_custom(func(x: SavedDataMapNode, y: SavedDataMapNode): return x.map_location.progress < y.map_location.progress)
	var lowest_progress: int = abs(data[0].map_location.progress)
	var highest_progress: int = data[data.size() - 1].map_location.progress
	
	var data_by_progress: Array = []
	for i in range(highest_progress + lowest_progress + 1):
		data_by_progress.append([])
	
	for map_node_data in data:
		data_by_progress[map_node_data.map_location.progress + lowest_progress].append(map_node_data)
	
	for progress_batch in data_by_progress:
		var lowest_lane_offset: int = abs(progress_batch.map(func(x: SavedDataMapNode): return x.map_location.lane).min())
		var even_lane_offset: int = -1 if progress_batch.size() in [2, 4] else 0
		if progress_batch.size() == 2 and progress_batch.any(func(x: SavedDataMapNode): return x.map_location.lane == -1):
			even_lane_offset = 1
		
		if lowest_lane_offset == 0: lowest_lane_offset = 1 # To center start node and the like
		
		for map_node_data in progress_batch:
			var MinimapNode: Control = MinimapNodePacked.instantiate()
			NodeParent.add_child(MinimapNode)
			var map_loc: MapLocation = map_node_data.map_location
			MinimapNode.position = (SPACING * Vector2(map_loc.progress + lowest_progress, map_loc.lane + lowest_lane_offset))
			MinimapNode.position.y += (SPACING.y / 2.0) * even_lane_offset
			MinimapNode.setInfo(onFindIconById(map_node_data.id), map_loc, map_node_data.links, map_node_data.is_entered)
			
	for MinimapNode in NodeParent.get_children():
		for map_link in MinimapNode.links:
			var MinimapLink: Sprite2D = MinimapLinkPacked.instantiate()
			Links.add_child(MinimapLink)
			
			var OtherNode: Control = onFindMapNodeByMapLocation(map_link.map_location)
			var start: Vector2 = MinimapNode.global_position + (MinimapNode.size / 2.0)
			var end: Vector2 = OtherNode.global_position + (OtherNode.size / 2.0)
			
			MinimapLink.setInfo(map_link)
			MinimapLink.global_position = lerp(start, end, 1 / 2.0) + Vector2(10, 10)
			
			MinimapLink.rotation = start.angle_to_point(end)
				
	
func onFindMapNodeByMapLocation(map_location: MapLocation) -> Control:
	for MinimapNode in NodeParent.get_children():
		if MinimapNode.map_location.progress == map_location.progress and MinimapNode.map_location.lane == map_location.lane:
			return MinimapNode
	return null
	
func onFindIconById(id: int) -> Texture2D:
	for id_to_icon in id_to_icons:
		if id == id_to_icon.id: return id_to_icon.icon
	return null

func getData() -> Array:
	var data: Array = Game.area.map_nodes_data
	if data.is_empty(): return SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapNodesGD"))
	return data

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
