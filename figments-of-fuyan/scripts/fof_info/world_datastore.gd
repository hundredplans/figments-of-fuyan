class_name WorldDatastore extends Resource

const CARD_RARITY_PRICES_DATASTORE_PATH: String = "res://resources/datastore/encounters/rarity_prices/card_rarity_prices.tres"
const BOON_RARITY_PRICES_DATASTORE_PATH: String = "res://resources/datastore/encounters/rarity_prices/boon_rarity_prices.tres"
const TOOL_RARITY_PRICES_DATASTORE_PATH: String = "res://resources/datastore/encounters/rarity_prices/tool_rarity_prices.tres"

@export var world: int

@export_group("Base")
@export var base_rarity_odds: RarityOddsDatastore
@export_range(0, 1, 0.005) var base_tier_up_rate: float
@export_group("")

@export_group("Level")
@export var fight_rewards: FightRewardsDatastore
@export var elite_fight_rewards: FightRewardsDatastore
@export_range(0, 1, 0.005) var elite_fight_rewards_second_item_odds: float
@export var budget_for_fights: Array[int]
@export var elite_fights_budget_offset: int
@export_range(0, 1, 0.005) var enemy_tier_up_rate: float
@export_range(0, 1, 0.005) var elite_enemy_tier_up_rate: float
@export_group("")

@export_group("Tools")
@export_range(0, 1, 0.005) var tool_enemy_spawn_rate: float
@export_range(0, 1, 0.005) var tool_enemy_spawn_rate_tier_up: float
@export_group("")

@export_group("Map")
@export_range(0, 1, 0.01) var UPGRADE_REGULAR_FIGHT: float = 0.125
@export_group("")

@export_group("Constants across Worlds")
@export var MIN_ELITE_FIGHTS: int = 2
@export_range(0, 100, 1) var foreigner_mult: float = 1.5
@export_range(0, 10, 1) var default_shop_variance: int = 3
@export_range(0, 1, 0.005) var card_with_tool_odds: float = 0.025
@export_group("")

static func getInfoPath() -> String: return "res://resources/datastore/world"
	
func getMaxEnergy() -> int:
	return world + 4

func getEnemySpawnRarityOdds() -> RarityOddsDatastore:
	return base_rarity_odds

func getToolEnemySpawnRarityOdds() -> RarityOddsDatastore:
	return base_rarity_odds
	
func getToolEnemySpawnTierOdds() -> float:
	return tool_enemy_spawn_rate_tier_up
	
func getBaseRarityOdds() -> RarityOddsDatastore:
	return base_rarity_odds

#region Reward
func getToolRewardRarityOdds(is_elite_or_epic: bool) -> RarityOddsDatastore:
	var rewards_datastore := getEliteFightRewardsDatastore() if is_elite_or_epic else getFightRewardsDatastore()
	return rewards_datastore.getToolRarityOdds()
	
func getToolRewardTierUpOdds(is_elite_or_epic: bool) -> float:
	var rewards_datastore := getEliteFightRewardsDatastore() if is_elite_or_epic else getFightRewardsDatastore()
	return rewards_datastore.getToolTierUpOdds()
	
func getBoonRewardRarityOdds(is_elite_or_epic: bool) -> RarityOddsDatastore:
	var rewards_datastore := getEliteFightRewardsDatastore() if is_elite_or_epic else getFightRewardsDatastore()
	return rewards_datastore.getBoonRarityOdds()
	
func getBoonRewardTierUpOdds(is_elite_or_epic: bool) -> float:
	var rewards_datastore := getEliteFightRewardsDatastore() if is_elite_or_epic else getFightRewardsDatastore()
	return rewards_datastore.getBoonTierUpOdds()
	
func getEliteFightRewardsDatastore() -> FightRewardsDatastore:
	return elite_fight_rewards
	
func getFightRewardsDatastore() -> FightRewardsDatastore:
	return fight_rewards
	
func getCardRarityPrices() -> RarityPriceDatastore:
	return load(CARD_RARITY_PRICES_DATASTORE_PATH)
	
func getToolRarityPrices() -> RarityPriceDatastore:
	return load(TOOL_RARITY_PRICES_DATASTORE_PATH)
	
func getBoonRarityPrices() -> RarityPriceDatastore:
	return load(BOON_RARITY_PRICES_DATASTORE_PATH)
#endregion

func getPriceVariance() -> int:
	return default_shop_variance
	
func getCardWithToolOdds() -> float:
	return card_with_tool_odds
	
func getCardWithToolTierUpOdds() -> float:
	return base_tier_up_rate

func getBaseTierUpOdds() -> float:
	return base_tier_up_rate

func getForeignerMult() -> float:
	return foreigner_mult
