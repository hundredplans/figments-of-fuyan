class_name ShopItemDatastore extends Resource

enum ItemType {CARD, TOOL, BOON}
@export var item_type: ItemType
@export var rarity_odds_datastore: RarityOddsDatastore
@export var rarity_price_datastore: RarityPriceDatastore
@export var position: Vector2

func getRarityOddsDatastore() -> RarityOddsDatastore:
	return rarity_odds_datastore if rarity_odds_datastore != null\
		else Game.getArea().getWorld().getBaseRarityOdds()
		
func getRarityPriceDatastore() -> RarityPriceDatastore:
	return rarity_price_datastore

func getPriceVariance() -> int:
	return Game.getArea().getWorld().getPriceVariance()

func getTierUpOdds() -> float:
	return Game.getArea().getWorld().getBaseTierUpOdds()
	
func getPosition() -> Vector2:
	return position
