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

static func getBool() -> bool:
	return randf() > 0.5

static func rollFloat(x: float) -> bool:
	return x > randf()

static func getRandomCardData(keep_ids: Array, odds_datastore: RarityOddsDatastore, tool_odds_datastore: RarityOddsDatastore,\
base_tier: int, tier_up_odds: float, tool_odds: float, tool_tier_up_odds: float, used_ids: Array = []) -> SavedDataCard:
	if base_tier == 0: base_tier = Game.getArea().getWorldDifficulty()
	var odds: Dictionary = odds_datastore.getDictionary()
	
	var attempts: int = 0
	var max_attempts: int = 8
	while (attempts < max_attempts):
		@warning_ignore("int_as_enum_without_cast")
		var rarity: Game.Rarities = int(Random.getRandomKey(odds))
		var card_infos: Array = Helper.getFofInfoArray(CardInfo)
		
		if !keep_ids.is_empty(): card_infos = card_infos.filter(func(x: CardInfo): return x.id in keep_ids)
		card_infos = card_infos.filter(func(x: CardInfo): return x.rarity == rarity)
		
		if !used_ids.is_empty():
			card_infos = card_infos.filter(func(x: CardInfo): return x.id not in used_ids)
		
		if card_infos.is_empty(): return null
		
		return getCardDataFromInfo(card_infos.pick_random(), base_tier, tier_up_odds, tool_odds_datastore, tool_odds, tool_tier_up_odds)
	return null
	
static func getCardDataFromInfo(card_info: CardInfo, base_tier: int, tier_up_odds: float, tool_odds_datastore: RarityOddsDatastore, tool_odds: float, tool_tier_up_odds: float) -> SavedDataCard:
	var card_tier: int = min(base_tier + int(Random.rollFloat(tier_up_odds)), Game.MAX_CARD_TIER)
	var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
	card_data.tier = card_tier
	Game.setCardDataFromInfo(card_data, card_info)
	
	if Random.rollFloat(tool_odds):
		card_data.tool_data = getRandomToolData(tool_odds_datastore, tool_tier_up_odds, base_tier)
	return card_data
	
static func getRandomLocalCardData(odds_datastore: RarityOddsDatastore, tool_odds_datastore: RarityOddsDatastore,\
base_tier: int, tier_up_odds: float, tool_odds: float, tool_tier_up_odds: float, used_ids: Array = []) -> SavedDataCard:
	var keep_ids: Array = Game.getArea().getBasicCardIds()
	return getRandomCardData(keep_ids, odds_datastore, tool_odds_datastore, base_tier, tier_up_odds, tool_odds, tool_tier_up_odds, used_ids)
	
	
static func getRandomToolData(odds_datastore: RarityOddsDatastore, tier_up_odds: float,\
base_tier: int = Game.getArea().getWorldDifficulty(), used_ids: Array = []) -> SavedDataTool:
	var odds: Dictionary = odds_datastore.getDictionary()
	
	var attempts: int = 0
	var max_attempts: int = 8
	while (attempts < max_attempts):
		@warning_ignore("int_as_enum_without_cast")
		var rarity: Game.Rarities = int(Random.getRandomKey(odds))
		var tool_infos: Array = Helper.getFofInfoArray(ToolInfo)
		var tool_tier: int = min(base_tier + int(Random.rollFloat(tier_up_odds)), Game.MAX_TOOL_TIER)
		tool_infos = tool_infos.filter(func(x: ToolInfo): return x.rarity == rarity)
		
		if !used_ids.is_empty():
			tool_infos = tool_infos.filter(func(x: ToolInfo): return x.id not in used_ids)
		
		if tool_infos.is_empty(): return null
		var tool_info: ToolInfo = tool_infos.pick_random()
		var tool_data: SavedDataTool = tool_info.saved_data.new(tool_info.id, true)
		tool_data.tier = tool_tier
		return tool_data
	return null
	
static func getRandomBoonData(odds_datastore: RarityOddsDatastore, tier_up_odds: float,\
base_tier: int = Game.getArea().getWorldDifficulty(), used_ids: Array = []) -> SavedDataBoon:
	var odds: Dictionary = odds_datastore.getDictionary()
	
	var attempts: int = 0
	var max_attempts: int = 8
	while (attempts < max_attempts):
		@warning_ignore("int_as_enum_without_cast")
		var rarity: Game.Rarities = int(Random.getRandomKey(odds))
		var boon_infos: Array = Helper.getFofInfoArray(BoonInfo)
		var boon_tier: int = min(base_tier + int(Random.rollFloat(tier_up_odds)), Game.MAX_BOON_TIER)
		boon_infos = boon_infos.filter(func(x: BoonInfo): return x.rarity == rarity)
		boon_infos = boon_infos.filter(onBoonDoesntExistAtTier.bind(boon_tier))
		
		if !used_ids.is_empty():
			boon_infos = boon_infos.filter(func(x: BoonInfo): return x.id not in used_ids)
		
		if boon_infos.is_empty(): return null
		var boon_info: BoonInfo = boon_infos.pick_random()
		var boon_data: SavedDataBoon = boon_info.saved_data.new(boon_info.id, true)
		boon_data.tier = boon_tier
		return boon_data
	return null

static func onBoonDoesntExistAtTier(boon_info: BoonInfo, tier: int) -> bool:
	var existing_boons: Array = Game.getSaveFile().getBoons()
	if existing_boons.is_empty(): return true
	return !existing_boons.any(func(x: BoonGD):\
		return x.info.id == boon_info.id and x.getTier() == tier)
