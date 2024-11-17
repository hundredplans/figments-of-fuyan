class_name WorldDatastore extends Resource

@export var world: int
@export var data: Array[MapNodeOddsDatastore]

@export_group("Start of Generation")
@export_range(0, 100, 0.1) var unique_node_segment_one_odds: float
@export_range(0, 100, 0.1) var unique_node_segment_two_odds: float
@export_group("")

@export_group("Fight Rewards")
@export var fight_rewards: FightRewardsDatastore
@export var elite_fight_rewards: FightRewardsDatastore
@export_group("")

@export_group("Tools")
@export var tool_enemy_spawn_rarity_odds: RarityOddsDatastore
@export_range(0, 100, 0.1) var tool_enemy_spawn_rate: float
@export_range(0, 100, 0.1) var tool_enemy_ascended_rate: float
@export_group("")

@export_group("Random Spawns")
@export_range(0, 100, 0.1) var enemy_ascended_rate: float
@export_group("")

@export_group("Constants across Worlds")
@export var LANE_ODDS: Dictionary = {
	"2": 0.25,
	"3": 0.7,
	"4": 0.05, 
}
@export var REMOVE_RANDOM_EDGES: float = 0.5

static func getInfoPath() -> String: return "res://resources/datastore/world"
	
func getMaxEnergy() -> int:
	return world + 4
