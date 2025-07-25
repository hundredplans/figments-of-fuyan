class_name Random

static func setSeed(_my_seed: int) -> void:
	seed(1)

static func getRandomKey(odds: Dictionary) -> String:
	var roll: float = randf()
	var total: float = 0
	for key in odds:
		if roll < odds[key] + total: return str(key)
		total += odds[key]
	push_error("Odds don't add up to 1")
	return ""
	
static func getRandomKeyVariant(odds: Dictionary) -> Variant:
	var roll: float = randf()
	var total: float = 0
	for key in odds:
		if roll < odds[key] + total: return key
		total += odds[key]
	push_error("Odds don't add up to 1")
	return null
	
static func onConvertPercentOdds(odds: Dictionary) -> Dictionary:
	var new_odds: Dictionary = {}
	for key in odds.keys():
		new_odds[key] = (odds[key] / 100.0)
	return new_odds

static func getBool() -> bool:
	return randf() > 0.5

static func rollFloat(x: float) -> bool:
	return x > randf()

static func getRandomFofInRarity(type: GDScript, rarity: Game.Rarities) -> SavedData:
	var arr: Array = Helper.getFofInfoArray(type)
	arr = arr.filter(func(x: FofInfo): return x.rarity == rarity)
	
	if type == BoonInfo:
		var boon_ids: Array = Game.save_file.boons.filter(func(x: BoonGD): return x.tier == 4).map(func(y: BoonGD): return y.info.id)
		arr = arr.filter(func(x: BoonInfo): return x.id not in boon_ids)
	
	if arr.is_empty(): return null
	var info: FofInfo = arr.pick_random()
	
	var data: SavedData = Game.setCardDataFromInfo(SavedDataCard.new(info.id, true), info) if info is CardInfo else info.saved_data.new(info.id, true)
	return data
	
static func getRandomFofByOdds(type: GDScript, odds: Dictionary = Game.area.getWorld().base_rarity_odds.getDictionary()) -> SavedData:
	@warning_ignore("int_as_enum_without_cast")
	var rarity: Game.Rarities = int(Random.getRandomKey(Random.onConvertPercentOdds(odds)))
	return Random.getRandomFofInRarity(type, rarity)
	
# Area id = 0 if we want all cards
static func getRandomCardData(ids: Array, odds: Dictionary, tool_chance: float, tool_tier_up_rate: float, tool_odds: Dictionary, tier_up_rate: float, base_tier: int) -> SavedDataCard:
	var attempts: float = 0
	var total_attempts: float = 16
	while(attempts < total_attempts):
		var card_infos: Array = ids.map(func(x: int): return Helper.getFofInfoID(CardInfo, x))
		
		@warning_ignore("int_as_enum_without_cast")
		var rarity: Game.Rarities = int(getRandomKey(onConvertPercentOdds(odds)))
		card_infos = card_infos.filter(func(x: CardInfo): return x.rarity == rarity)
		
		if card_infos.is_empty(): attempts += 1; break
		var chosen_info: CardInfo = card_infos.pick_random()
		
		var tier_up_card: bool = rarity != Game.Rarities.EXALT and Random.rollFloat(tier_up_rate)
		var tool_data: SavedDataTool = null
		if Random.rollFloat(tool_chance):
			tool_data = getRandomFofByOdds(ToolInfo, tool_odds)
			var roll_tool_tier_up: bool = rollFloat(tool_tier_up_rate)
			tool_data.tier = base_tier
			if roll_tool_tier_up: tool_data.onTierUp()
		
		var tier: int = base_tier
		if tier_up_card: tier = min(tier + 1, 4)
		
		var card_data: SavedDataCard = Game.onCreateBaseCard(chosen_info.id, tier, tool_data)
		return card_data
	return null
