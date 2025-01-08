class_name WorldDatastore extends Resource

@export var world: int
@export var data: Array[MapNodeOddsDatastore]

@export_group("Base")
@export var base_rarity_odds: RarityOddsDatastore
@export_range(0, 100, 0.1) var base_ascended_rate: float
@export_group("")

@export_group("Start of Generation")
@export_range(0, 100, 0.1) var extra_unique_node_odds: float
@export_range(0, 100, 0.1) var extra_shop_odds: float
@export_group("")

@export_group("Level")
@export var enemy_spawn_rarity_odds: RarityOddsDatastore
@export var fight_rewards: FightRewardsDatastore
@export var elite_fight_rewards: FightRewardsDatastore
@export var progress_enemy_energy_budget: Array[int]
@export var elite_fights_budget_offset: int
@export_range(0, 100, 0.1) var enemy_ascended_rate: float
@export_range(0, 100, 0.1) var elite_enemy_ascended_rate: float
@export_group("")

@export_group("Tools")
@export var tool_enemy_spawn_rarity_odds: RarityOddsDatastore
@export_range(0, 100, 0.1) var tool_enemy_spawn_rate: float
@export_range(0, 100, 0.1) var tool_enemy_ascended_rate: float
@export_group("")

@export_group("Shop")
@export_subgroup("Price")
@export var card_rarity_prices: RarityPriceDatastore
@export var tool_rarity_prices: RarityPriceDatastore
@export var boon_rarity_prices: RarityPriceDatastore
@export_range(0, 100, 1) var foreign_card_base_price_increase: int
@export_range(0, 100, 1) var transform_by_rarity_price: int
@export_range(0, 100, 1) var transform_by_cost_price: int
@export_range(0, 100, 1) var ascend_card_price: int
@export_range(0, 100, 1) var remove_card_price: int
@export_subgroup("")

@export var shop_rarity_odds: RarityOddsDatastore
@export_range(0, 100, 1) var ascended_items_flat_after_percentage_increase: int
@export_range(0, 100, 1) var ascended_items_price_percentage_increase: int
@export_range(0, 100, 0.1) var shop_ascension_chance: float
@export_range(0, 10, 1) var default_shop_variance: int
@export_group("")

@export_group("Constants across Worlds")
@export var LANE_ODDS: Dictionary = {
	"2": 0.25,
	"3": 0.7,
	"4": 0.05, 
}
@export var REMOVE_RANDOM_EDGES: float = 0.5
@export var ENCOUNTER_COUNT_FIGHT_ODDS: Dictionary = {
	"1": 0,
	"2": 0,
	"3": 0.25,
	"4": 0.5,
	"5": 1.0
}
@export_group("")

static func getInfoPath() -> String: return "res://resources/datastore/world"
	
func getMaxEnergy() -> int:
	return world + 4
