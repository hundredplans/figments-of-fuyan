class_name ShopItemDatastore extends Resource

enum ItemType {CARD, TOOL, BOON}
@export var item_type: ItemType
@export var price_variance: int
@export var tier_up_flat_price_increase: int
@export var rarity_odds_datastore: RarityOddsDatastore
@export var rarity_price_datastore: RarityPriceDatastore
@export var card_tool_rarity_price_datastore: RarityPriceDatastore
@export_range(0, 1, 0.01) var tier_up_percentage_increase: float
@export var position: Vector2

@export_group("Default")
@export var use_default_prices: bool
@export var use_default_odds: bool
@export var use_default_price_variance: int
@export_group("")
