extends EncounterGD

const TOOL_ODDS: float = 0.34
const CARD_ODDS: float = 0.33
const BOON_ODDS: float = 0.33
const FOREIGN_ODDS: float = 0.25

var reward_data: SavedData
var junk_man_value: int

const WORLD_DIFFICULTY_TO_MAX_VALUE: Dictionary[int, int] = {
	1: 40,
	2: 60,
	3: 80
}

func onSave() -> SavedDataEncounter:
	ability_save['junk_man_value'] = junk_man_value
	ability_save['reward_data'] = reward_data
	return super()
	
func setJunkManValue(_junk_man_value: int) -> void:
	junk_man_value = _junk_man_value
	
func getJunkManValue() -> int:
	return junk_man_value
	
func getRewardData() -> SavedData:
	return reward_data
	
func onCreateRewardData() -> void:
	var odds: Dictionary = {"CardInfo": CARD_ODDS, "BoonInfo": BOON_ODDS, "ToolInfo": TOOL_ODDS}
	var rarity_odds: RarityOddsDatastore = Game.getArea().getWorld().getBaseRarityOdds()
	var base_tier: int = Game.getArea().getWorldDifficulty()
	var type: String = Random.getRandomKey(odds)
	match type:
		"CardInfo":
			var is_foreign: bool = Random.rollFloat(FOREIGN_ODDS)
			if !is_foreign: reward_data = Random.getRandomLocalCardData(rarity_odds, null, base_tier, 0.0, 0.0, 0.0)
			else: reward_data = Random.getRandomCardData([], rarity_odds, null, base_tier, 0.0, 0.0, 0.0)
		"BoonInfo": reward_data = Random.getRandomBoonData(rarity_odds, 0.0, base_tier)
		"ToolInfo": reward_data = Random.getRandomToolData(rarity_odds, 0.0, base_tier)
	reward_data.public_id = 0
	
func getFillBarForegroundColor() -> Color: return Color("#634400")
func getFillBarBackgroundColor() -> Color: return Color("#ad7600")

func isDragZone() -> bool: return true
func getMaxValue() -> int:
	return WORLD_DIFFICULTY_TO_MAX_VALUE[Game.getArea().getWorldDifficulty()]

func onRewardCollected(item: FofGD) -> void:
	if reward_data == null: return
	reward_data = null
	
	if item is CardGD:
		var item_data: SavedData = item.onSave()
		item_data.public_id = 0
		
		var NewItem: FofGD = SavedData.onLoadModel(item_data, Game.getSaveFile())
		onPushAction(AddToDeckAction.new(NewItem))
	elif item is BoonGD:
		onPushAction(AddBoonAction.new(item.info.id, item.getTier()))
