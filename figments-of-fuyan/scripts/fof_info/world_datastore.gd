class_name WorldDatastore extends Resource

@export var world: int

@export_group("Base")
@export var base_rarity_odds: RarityOddsDatastore
@export_range(0, 100, 0.1) var base_tier_up_rate: float
@export_group("")

@export_group("Level")
@export var enemy_spawn_rarity_odds: RarityOddsDatastore
@export var fight_rewards: FightRewardsDatastore
@export var elite_fight_rewards: FightRewardsDatastore
@export_range(0, 100, 0.1) var elite_fight_rewards_second_item_odds: float
@export var budget_for_fights: Array[int]
@export var elite_fights_budget_offset: int
@export_range(0, 100, 0.1) var enemy_tier_up_rate: float
@export_range(0, 100, 0.1) var elite_enemy_tier_up_rate: float
@export_group("")

@export_group("Tools")
@export var tool_enemy_spawn_rarity_odds: RarityOddsDatastore
@export_range(0, 100, 0.1) var tool_enemy_spawn_rate: float
@export_range(0, 100, 0.1) var tool_enemy_spawn_rate_tier_up: float
@export_group("")

@export_group("Shop")
@export_subgroup("Price")
@export var card_rarity_prices: RarityPriceDatastore
@export var tool_rarity_prices: RarityPriceDatastore
@export var boon_rarity_prices: RarityPriceDatastore
@export_range(0, 100, 1) var foreign_card_base_price_increase: int
@export_range(0, 100, 1) var transform_by_rarity_price: int
@export_range(0, 100, 1) var transform_by_cost_price: int
@export_range(0, 100, 1) var remove_card_price: int
@export_subgroup("")

@export var shop_rarity_odds: RarityOddsDatastore
@export_range(0, 10, 1) var default_shop_variance: int
@export_group("")

@export_group("Map")
@export_range(0, 1, 0.01) var UPGRADE_REGULAR_FIGHT: float = 0.125
@export_group("")

@export_group("Constants across Worlds")
@export var ENCOUNTER_COUNT_FIGHT_ODDS: Dictionary = {
	"1": 0,
	"2": 0,
	"3": 0.25,
	"4": 0.5,
	"5": 1.0
}
@export var MIN_ELITE_FIGHTS: int = 2
@export var MIN_ENCOUNTER_AMOUNT: int = 1
@export var MAX_ENCOUNTER_AMOUNT: int = 2
@export_group("")

static func getInfoPath() -> String: return "res://resources/datastore/world"
	
func getMaxEnergy() -> int:
	return world + 4

func getEncounterAmount() -> int:
	return randi_range(MIN_ENCOUNTER_AMOUNT, MAX_ENCOUNTER_AMOUNT)
