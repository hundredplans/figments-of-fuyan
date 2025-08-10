class_name FightRewardsDatastore extends Resource

@export var shillings_min: int
@export var shillings_max: int

@export_range(0, 1, 0.005) var boon_odds: float
@export_range(0, 1, 0.005) var tool_odds: float
@export_range(0, 1, 0.005) var tool_tier_up_rate: float
@export_range(0, 1, 0.005) var boon_tier_up_rate: float
@export_range(0, 1, 0.005) var card_tier_up_rate: float
@export_range(0, 1, 0.005) var card_tool_odds: float
@export_range(0, 1, 0.005) var card_tool_tier_up_rate: float

func getCardRarityOdds() -> RarityOddsDatastore:
	return Game.getWorld().getBaseRarityOdds()

func getCardToolRarityOdds() -> RarityOddsDatastore:
	return Game.getWorld().getBaseRarityOdds()

func getToolRarityOdds() -> RarityOddsDatastore:
	return Game.getWorld().getBaseRarityOdds()
	
func getBoonRarityOdds() -> RarityOddsDatastore:
	return Game.getWorld().getBaseRarityOdds()

func getToolOdds() -> float:
	return tool_odds

func getBoonOdds() -> float:
	return boon_odds
	
func getToolTierUpOdds() -> float:
	return tool_tier_up_rate
	
func getBoonTierUpOdds() -> float:
	return boon_tier_up_rate
	
func getCardTierUpOdds() -> float:
	return card_tier_up_rate
	
func getCardToolOdds() -> float:
	return card_tool_odds
	
func getCardToolTierUpOdds() -> float:
	return card_tool_tier_up_rate
