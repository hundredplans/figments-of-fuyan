class_name ShopCardDatastore extends ShopItemDatastore

@export_range(0, 1, 0.01) var foreign_odds: float
func getForeignOdds() -> float:
	return foreign_odds

func getToolOddsDatastore() -> RarityOddsDatastore:
	return Game.getArea().getWorld().getBaseRarityOdds()

func getToolOdds() -> float:
	return Game.getArea().getWorld().getCardWithToolOdds()
	
func getToolTierUpOdds() -> float:
	return Game.getArea().getWorld().getCardWithToolTierUpOdds()
