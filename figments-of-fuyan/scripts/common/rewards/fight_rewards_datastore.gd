class_name FightRewardsDatastore extends Resource

@export var shillings_min: int
@export var shillings_max: int

@export_group("Boon")
@export var boon_rarity_odds: RarityOddsDatastore
@export_range(0, 100, 0.1) var boon_odds: float
@export_range(0, 100, 0.1) var boon_ascension_rate: float
@export_group("")

@export_group("Tool")
@export var tool_rarity_odds: RarityOddsDatastore
@export_range(0, 100, 0.1) var tool_odds: float
@export_range(0, 100, 0.1) var tool_ascension_rate: float
@export_group("")
