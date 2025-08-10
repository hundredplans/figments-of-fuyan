class_name WorldDatastore extends Resource

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

@export_group("Shop")
@export var card_rarity_prices: RarityPriceDatastore
@export var tool_rarity_prices: RarityPriceDatastore
@export var boon_rarity_prices: RarityPriceDatastore
@export_range(0, 100, 1) var foreign_card_base_price_increase: int
@export_range(0, 10, 1) var default_shop_variance: int
@export_group("")

@export_group("Rewards")
@export_range(0, 1, 0.005) var card_reward_tool_chance: float
@export_group("")

@export_group("Map")
@export_range(0, 1, 0.01) var UPGRADE_REGULAR_FIGHT: float = 0.125
@export_group("")

@export_group("Constants across Worlds")
@export var MIN_ELITE_FIGHTS: int = 2
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
	return card_rarity_prices
	
func getToolRarityPrices() -> RarityPriceDatastore:
	return tool_rarity_prices
	
func getBoonRarityPrices() -> RarityPriceDatastore:
	return boon_rarity_prices
#endregion
