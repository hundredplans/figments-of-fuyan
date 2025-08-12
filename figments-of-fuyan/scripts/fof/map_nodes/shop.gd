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
	var existing_tool_ids: Array = []
	var existing_boon_ids: Array = []
	var existing_card_ids: Array = []
	var non_foreign_ids: Array = Game.getArea().getBasicCardIds()
	
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
					keep_ids = non_foreign_ids.duplicate()
				data = Random.getRandomCardData(keep_ids, odds_datastore, tool_odds_datastore, base_tier,\
					tier_up_odds, tool_odds, tool_tier_up_odds, existing_card_ids)
				existing_card_ids.append(data.id)
			ShopItemDatastore.ItemType.BOON:
				data = Random.getRandomBoonData(odds_datastore, tier_up_odds, base_tier, existing_boon_ids)
				existing_boon_ids.append(data.id)
			ShopItemDatastore.ItemType.TOOL:
				data = Random.getRandomToolData(odds_datastore, tier_up_odds, base_tier, existing_tool_ids)
				existing_tool_ids.append(data.id)
		
		var price_variance: int = shop_item.getPriceVariance()
		var price: int = (Game.getPriceForItemData(data) if data is not SavedDataCard else Game.getPriceForCardData(data, data.id not in non_foreign_ids))\
		+ randi_range(-price_variance, price_variance)
		
		var get_shop_price_action := GetShopPriceAction.new(price, self)
		onForceAction(get_shop_price_action)
		price = get_shop_price_action.getFinalPrice()
		
		var price_datastore := PriceDatastore.new(price, data, shop_item.getPosition())
		items.append(price_datastore)
		
func onItemBought(price_datastore: PriceDatastore) -> void:
	price_datastore.bought = true
	onPushAction(ChangeShillingsAction.new(-price_datastore.price))
	
	if price_datastore.getData() is SavedDataCard:
		var card_data: SavedDataCard = price_datastore.getData()
		card_data.public_id = 0
		if card_data.tool_data != null:
			card_data.tool_data.public_id = 0
		var Card: CardGD = SavedData.onLoadModel(card_data, Game.getSaveFile())
		onPushAction(AddToDeckAction.new(Card))
	elif price_datastore.getData() is SavedDataTool: # Stash screen handles this
		pass
	elif price_datastore.getData() is SavedDataBoon:
		var boon_data: SavedDataBoon = price_datastore.getData()
		onPushAction(AddBoonAction.new(boon_data.id, boon_data.tier))
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

func onUpdateHovered() -> void:
	if is_queued_for_deletion(): return
	var state: bool = getHoveredState()
	if state:
		if HoverUI != null: HoverUI.queue_free()
		HoverUI = load(getHoverUIPath()).instantiate()
	super()
	
func getHoverUIPath() -> String:
	return info.SHOP_HOVER_UI
#endregion
