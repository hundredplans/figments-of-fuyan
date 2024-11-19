extends MapNodeGD

#region Globals
var price_variance: int
#endregion

#region Saved Data
var available_items: Array # Array of saved datas
var purchased_items: Array # Array of saved datas
#endregion

#region Load / Save
func onFofInit() -> void:
	super()
	var area: AreaGD = get_tree().get_nodes_in_group("AreasGD")[0]
	var world_datastore: WorldDatastore = area.info.world
	onAddLocalForeignCardsBoonTools(world_datastore, area)
	onAddRemoveCard(world_datastore)
	onAddTransformation(world_datastore)
	
func onSave() -> SavedDataMapNode:
	return SavedDataShop.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, available_items, purchased_items)

func onLoadData(data: SavedData) -> void:
	super(data)
	available_items = data.available_items
	purchased_items = data.purchased_items
#endregion

#region Setting Prices
func onAddLocalForeignCardsBoonTools(world_datastore: WorldDatastore, area: AreaGD) -> void:
	var info_types: Array = [CardInfo, CardInfo, BoonInfo, ToolInfo]
	for i in range(info_types.size()):
		var objects: Array = Helper.getFofInfoArray(info_types[i])
		for j in range(2):
			var odds: Dictionary = world_datastore.shop_rarity_odds.getDictionary()
			var rarity: Game.Rarities = int(Random.getRandomKey(Random.onConvertPercentOdds(odds)))
			var rarity_objects: Array = objects.filter(func(x: FofInfo): return x.rarity == rarity)
			
			if i == 0: # Local cards only
				rarity_objects = rarity_objects.filter(func(x: CardInfo): return x.id in area.basic_card_ids)
			elif i == 1: # Non-local cards only (have to make it from this world only later)
				#TODO CHANGE TO x.id in area
				rarity_objects = rarity_objects.filter(func(x: CardInfo): return x.id in area.basic_card_ids)
			
			var picked_info: FofInfo = rarity_objects.pick_random()
			var picked_data: SavedData = picked_info.saved_data.new(picked_info.id, true)
			var ascend: bool = Random.rollFloat(world_datastore.shop_ascension_chance / 100.0)
			
			picked_data.ascended = ascend
			var fof_name: String = picked_info.getFofName().to_lower() # "Boon", "Card"
			var base_price: int = world_datastore.get(fof_name + "_rarity_prices").getByRarity(picked_info.rarity)
			if i == 1: # Extra base_price for foreign cards
				base_price += world_datastore.foreign_card_base_price_increase
			
			if ascend:
				base_price *= ((100 + world_datastore.ascended_items_price_percentage_increase) / 100.0)
				base_price += world_datastore.ascended_items_flat_after_percentage_increase
			var final_price: int = onAddPriceVariance(base_price)
			onAddToAvailableItems(PriceDatastore.new(final_price, picked_data))
	
func onAddRemoveCard(world_datastore: WorldDatastore) -> void:
	onAddToAvailableItems(PriceDatastore.new(world_datastore.remove_card_price, SavedDataMapEffect.new(3, true)))

func onAddTransformation(world_datastore: WorldDatastore) -> void:
	var transformation_ids: Array = [4, 5, 6]
	var id: int = transformation_ids.pick_random()
	var picked_data: SavedData = Helper.getFofInfoID(MapEffectInfo, id).saved_data.new(id, true)
	var base_price: int = 0
	match id:
		4: base_price = world_datastore.ascend_card_price
		5: base_price = world_datastore.transform_by_rarity_price
		6: base_price = world_datastore.transform_by_cost_price
		
	onAddToAvailableItems(PriceDatastore.new(base_price, picked_data))

func onAddToAvailableItems(price_datastore: PriceDatastore) -> void:
	available_items.append(price_datastore)
	
func onAddPriceVariance(price: int) -> int:
	return price + randi_range(-price_variance, price_variance)
#endregion
