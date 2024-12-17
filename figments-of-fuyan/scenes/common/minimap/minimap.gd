extends Control

@onready var ThreeLaner: Control = %ThreeLaner
@onready var FourLaner: Control = %FourLaner

@export var MinimapNodePacked: PackedScene
@export var temp_tx: Texture2D

func _ready() -> void:
	var data: Array = Game.area.map_nodes_data
	data.sort_custom(func(x: SavedDataMapNode, y: SavedDataMapNode): return x.map_location.progress < y.map_location.progress)
	var lowest_progress: int = data[0].map_location.progress
	var highest_progress: int = data[data.size() - 1].map_location.progress
	
	var data_by_progress: Array = []
	data_by_progress.resize(highest_progress + abs(lowest_progress))
	data_by_progress.fill([])
	
	for map_node_data in data:
		data_by_progress[map_node_data.map_location.progress + abs(lowest_progress)].append(map_node_data)
	
	for progress_batch in data_by_progress:
		progress_batch.sort_custom(func(x: SavedDataMapNode, y: SavedDataMapNode): return x.map_location.lane < y.map_location.lane)
		var is_four_laner: bool = progress_batch.size() == 4
		for map_node_data in progress_batch:
			var MinimapNode: Control = MinimapNodePacked.instantiate()
			var SpacerNode: Control = MinimapNodePacked.instantiate()
			MinimapNode.setInfo(temp_tx)
			
			var TrueParent: Control = ThreeLaner if !is_four_laner else FourLaner
			var SpacerParent: Control = ThreeLaner if is_four_laner else FourLaner
			
			#TrueParent.get_child().add_child(MinimapNode)
			SpacerNode.add_child(SpacerNode)
			
		var SpacerParent: Control = ThreeLaner if is_four_laner else FourLaner
		var lowest_lane_offset: int = progress_batch[0].map_location.lane
		#SpacerParent.get_child()
			
	#for node in 
	
