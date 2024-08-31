class_name WorldDatastore extends Resource

@export var world: int
@export var data: Array[MapNodeOddsDatastore]

@export_group("Start of Generation")
@export_range(0, 100, 0.1) var unique_node_segment_one_odds: float
@export_range(0, 100, 0.1)  var unique_node_segment_two_odds: float
@export_group("")

@export_group("Constants across Worlds")
@export var LANE_ODDS: Dictionary = {
	"2": 0.25,
	"3": 0.7,
	"4": 0.05, 
}
@export var REMOVE_RANDOM_EDGES: float = 0.5

static func getInfoPath() -> String: return "res://resources/datastore/world"
	
