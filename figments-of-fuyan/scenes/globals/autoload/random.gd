class_name Random

static func setSeed(_my_seed: int) -> void:
	seed(1)

static func getRandomKey(odds: Dictionary) -> String:
	var roll: float = randf()
	var total: float = 0
	for key in odds:
		if roll < odds[key] + total: return str(key)
		total += odds[key]
	return str(odds[odds.size() - 1])
	
static func getRandomKeyVariant(odds: Dictionary) -> Variant:
	var roll: float = randf()
	var total: float = 0
	for key in odds:
		if roll < odds[key] + total: return key
		total += odds[key]
	return odds[odds.size() - 1]
	
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
		var boon_ids: Array = Game.save_file.boons.filter(func(x: BoonGD): return x.ascended).map(func(y: BoonGD): return y.info.id)
		arr = arr.filter(func(x: BoonInfo): return x.id not in boon_ids)
	
	if arr.is_empty(): return null
	var info: FofInfo = arr.pick_random()
	
	var data: SavedData = Game.setCardDataFromInfo(SavedDataCard.new(info.id, true), info) if info is CardInfo else info.saved_data.new(info.id, true)
	var ascenscion_roll_odds: float = Game.area.getWorld().base_ascended_rate / 100.0
	
	if type == BoonInfo:
		ascenscion_roll_odds = Game.onAddDivinusBoonAscenscionOdds(ascenscion_roll_odds)
	
	data.ascended = Random.rollFloat(ascenscion_roll_odds)
	return data
	
static func getRandomFofByOdds(type: GDScript, odds: Dictionary = Game.area.getWorld().base_rarity_odds.getDictionary()) -> SavedData:
	@warning_ignore("int_as_enum_without_cast")
	var rarity: Game.Rarities = int(Random.getRandomKey(Random.onConvertPercentOdds(odds)))
	return Random.getRandomFofInRarity(type, rarity)
