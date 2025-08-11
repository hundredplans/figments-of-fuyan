extends MapNodeGD

#region Globals
const GENERAL_SHOP_DATASTORE_PATH: String = "res://resources/datastore/shops/shop_datastore/general_shop_datastore.tres"
var shop_datastore: ShopDatastore

const SHOP_MUSIC_PATH: String = "res://assets/sounds/music/shop.mp3"
#endregion

#region Saved Data
var items: Array # [PriceDatastore]
#endregion

#region Load / Save
func onFofInit() -> void:
	super()
	onLoadShopDatastore()
		
func onSave() -> SavedDataMapNode:
	return SavedDataShop.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, items)

func onLoadData(data: SavedData) -> void:
	super(data)
	items = data.items
	onLoadShopDatastore()
#endregion

#region Setting Prices
func onCreateItems() -> void:
	for shop_item: ShopItemDatastore in shop_datastore.getItems():
		var data: SavedData
		var odds_datastore := shop_item.getRarityOddsDatastore()
		var base_tier: int = Game.getArea().getWorldDifficulty()
		var tier_up_odds: float = shop_item.getTierUpOdds()
		match shop_item.item_type:
			ShopItemDatastore.ItemType.CARD:
				var is_foreign: bool = Random.rollFloat(shop_item.getForeignOdds())
				var keep_ids: Array = []
				var tool_odds_datastore: RarityOddsDatastore = shop_item.getToolOddsDatastore()
				var tool_odds: float = shop_item.getToolOdds()
				var tool_tier_up_odds: float = shop_item.getToolTierUpOdds()
				if !is_foreign:
					keep_ids = Game.getArea().getBasicCardIds()
				data = Random.getRandomCardData(keep_ids, odds_datastore, tool_odds_datastore, base_tier,\
					tier_up_odds, tool_odds, tool_tier_up_odds)
			ShopItemDatastore.ItemType.BOON:
				data = Random.getRandomBoonData(odds_datastore, tier_up_odds, base_tier)
				pass
			ShopItemDatastore.ItemType.TOOL:
				data = Random.getRandomToolData(odds_datastore, tier_up_odds, base_tier)
		
		var price_variance: int = shop_item.getPriceVariance()
		var price: int = Game.getPriceForItemData(data) + randi_range(-price_variance, price_variance)
		
		var get_shop_price_action := GetShopPriceAction.new(price, self)
		onForceAction(get_shop_price_action)
		price = get_shop_price_action.getFinalPrice()
		
		var price_datastore := PriceDatastore.new(price, data, shop_item.getPosition())
		items.append(price_datastore)
#endregion

func onEntered() -> void:
	if !is_entered: # First time enter
		onCreateItems()
	super()
	onCreateScreen()
	onPushAction(PlayMusicAction.new(Audio.SHOP))
	
func onFinished() -> void:
	super()
	onPushAction(PlayMusicAction.new(Audio.BACKGROUND))
	
func onLoadShopDatastore() -> void:
	if shop_datastore != null: return
	var path: String
	match info.id:
		6: path = GENERAL_SHOP_DATASTORE_PATH
		_: path = GENERAL_SHOP_DATASTORE_PATH
	shop_datastore = load(path)

func getShopDatastore() -> ShopDatastore:
	return shop_datastore

func getItems() -> Array:
	return items
