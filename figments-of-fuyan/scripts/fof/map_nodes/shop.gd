extends MapNodeGD

#region Globals
var price_variance: int
var world_datastore: WorldDatastore

const QUENTIN_CRIMINAL_PRICE_INCREASE: float = 1.15
const DIVINUS_NOT_ON_HOLY_PATH_PRICE_INCREASE: float = 1.1
#endregion

#region Saved Data
var items: Array # Array of saved datas
#endregion

#region Load / Save
func onFofInit() -> void:
	super()
	onAddLocalForeignCardsBoonTools()
	
	if isFirstShop(): return # Doesn't activate on first shop
	onAddRemoveCard()
	onAddTransformation()
	
func onSave() -> SavedDataMapNode:
	return SavedDataShop.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, items)

func onLoadData(data: SavedData) -> void:
	super(data)
	items = data.items
	world_datastore = Game.area.getWorld()
	price_variance = world_datastore.default_shop_variance
#endregion

#region Setting Prices
func onAddLocalForeignCardsBoonTools() -> void:
	var info_types: Array = [CardInfo, BoonInfo, ToolInfo]
	for i in range(info_types.size()):
		var type: GDScript = info_types[i]
		var objects: Array = getAllObjects(type)
		for j in range(2 if type != CardInfo else 4):
			var foreign: bool = getForeign(type, j)
			var price_datastore: PriceDatastore = onRollFof(objects, type, foreign)
			if price_datastore == null: continue
			
			onAddToItems(price_datastore)
	
func getAllObjects(type: GDScript) -> Array:
	if isFirstShop() and type == CardInfo:
		return Helper.getFofInfoArray(type).filter(func(x: CardInfo): return x.energy < 4)
	return Helper.getFofInfoArray(type) if type != BoonInfo else Game.getAvailableBoons()
	
func getForeign(info_type: GDScript, j: int) -> bool:
	if isFirstShop(): return false
	if info_type == CardInfo:
		if j == 2: return Random.getBool()
		elif j == 3: return true
	return false
	
func isFirstShop() -> bool: return map_location.progress == 1 # DEBUG
	
func onAddRemoveCard() -> void:
	onAddToItems(PriceDatastore.new(world_datastore.remove_card_price, SavedDataMapEffect.new(3, true)))

func onAddTransformation() -> void:
	var transformation_ids: Array = [4, 5, 6]
	var id: int = transformation_ids.pick_random()
	var picked_data: SavedData = Helper.getFofInfoID(MapEffectInfo, id).saved_data.new(id, true)
	var base_price: int = 0
	match id:
		4: base_price = world_datastore.ascend_card_price
		5: base_price = world_datastore.transform_by_rarity_price
		6: base_price = world_datastore.transform_by_cost_price
		
	onAddToItems(PriceDatastore.new(base_price, picked_data))

func onAddToItems(price_datastore: PriceDatastore) -> void:
	items.append(price_datastore)
	
func onAddPriceVariance(price: int) -> int:
	return price + randi_range(-price_variance, price_variance)
#endregion

func onEntered() -> void:
	super()
	onCreateWorldScene()
	onCreateScreen()

#region Rolls
func onRerollBoon() -> PriceDatastore:
	var available_boons: Array = Game.getAvailableBoons()
	return onRollFof(available_boons, BoonInfo)
		
func onRollFof(objects: Array, script_type: GDScript, foreign: bool = false) -> PriceDatastore:
	if objects.is_empty(): return null
	var odds: Dictionary = world_datastore.shop_rarity_odds.getDictionary()
	@warning_ignore("int_as_enum_without_cast")
	var rarity: Game.Rarities = int(Random.getRandomKey(Random.onConvertPercentOdds(odds)))
	var rarity_objects: Array = objects.filter(func(x: FofInfo): return x.rarity == rarity)
	
	if script_type == CardInfo and !foreign: # Local cards only
		rarity_objects = rarity_objects.filter(func(x: CardInfo): return x.id in Game.area.basic_card_ids)
	elif script_type == CardInfo and foreign: # Non-local cards only (have to make it from this world only later)
		rarity_objects = rarity_objects.filter(func(x: CardInfo): return x.id not in Game.area.basic_card_ids)
	
	if rarity_objects.is_empty(): return
	
	var picked_info: FofInfo = rarity_objects.pick_random()
	objects.erase(picked_info)
	var picked_data: SavedData = picked_info.saved_data.new(picked_info.id, true)
	if picked_data is SavedDataCard:
		Game.setCardDataFromInfo(picked_data, picked_info)
	
	var ascend: bool = Random.rollFloat(world_datastore.shop_ascension_chance / 100.0)
	if script_type == BoonInfo and Game.isBoonAvailableUnascended(picked_data.id):
		ascend = false
	
	picked_data.ascended = ascend
	var fof_name: String = picked_info.get_script().getFofName().to_lower() # "Boon", "Card"
	var base_price: int = world_datastore.get(fof_name + "_rarity_prices").getByRarity(picked_info.rarity)
	if script_type == CardInfo and foreign: # Extra base_price for foreign cards
		base_price += world_datastore.foreign_card_base_price_increase
	
	if ascend:
		base_price = int(base_price * ((100 + world_datastore.ascended_items_price_percentage_increase) / 100.0))
		base_price += world_datastore.ascended_items_flat_after_percentage_increase
	var final_price: int = onAddPriceVariance(base_price)
	final_price = onApplyFinalPriceMultipliers(final_price)
	
	return PriceDatastore.new(final_price, picked_data)
#endregion

#region Final Price
func onApplyFinalPriceMultipliers(price: int) -> int:
	if Game.save_file.getChampionCard().info.id == 2:
		if !isHoly(): price = int(price * DIVINUS_NOT_ON_HOLY_PATH_PRICE_INCREASE)
		
	elif Game.save_file.getChampionCard().info.id == 3: # Quentin increase price
		price = int(price * QUENTIN_CRIMINAL_PRICE_INCREASE)
		
	return price
#endregion
