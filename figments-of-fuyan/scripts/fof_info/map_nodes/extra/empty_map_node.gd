class_name EmptyMapNode extends Resource

@export var id: int
@export var progress: int
@export var lane: int
@export var links: Array[EmptyMapNodeLink] = []
var map_location: MapLocation

func _init(_progress: int = 0, _lane: int = 0) -> void:
	progress = _progress
	lane = _lane
