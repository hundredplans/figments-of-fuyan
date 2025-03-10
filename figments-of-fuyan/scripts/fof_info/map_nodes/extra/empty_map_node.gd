class_name EmptyMapNode extends Resource

@export var id: int
@export var progress: int
@export var lane: int
@export var links: Array[EmptyMapNodeLink] = []
var map_location: MapLocation

func _init(_progress: int = 0, _lane: int = 0) -> void:
	progress = _progress
	lane = _lane

func isSegmentOne() -> bool:
	return progress > 0 and progress < 6
	
func isSegmentTwo() -> bool:
	return progress > 5

func isLink(empty_map_node: EmptyMapNode) -> bool:
	return empty_map_node in links.map(func(x: EmptyMapNodeLink): return x.empty_map_node)\
		or self in empty_map_node.links.map(func(x: EmptyMapNodeLink): return x.empty_map_node)
