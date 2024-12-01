extends EncounterGD

const FORCE_OPEN_CHANCE: float = 0.1
const ADMIRE_SHILLINGS: int = 5
const OPEN_SHILLINGS: int = 50
var rewards_page_title: String
var rewards: Rewards

func onFirstEntered(screen: Control) -> void:
	super(screen)
	var shilling_gain: MapEffectGD = Game.onCreateGainShillings(OPEN_SHILLINGS, self)
	var Boon: BoonGD = SavedData.onLoadModel(Random.getRandomFofByBaseOdds(BoonInfo), self)
	var Tool: ToolGD = SavedData.onLoadModel(Random.getRandomFofByBaseOdds(ToolInfo), self)
	rewards = Rewards.new([shilling_gain, Boon, Tool])
	
func onEntered(screen: Control) -> void:
	super(screen)
	if rewards.taken_items.is_empty() or rewards.items.is_empty(): return
	onCreateRewardsUI("OpenPage", screen)
	
func canShowUp() -> bool:
	return anyRequirementMet()
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		"Open": return Game.playerHasTool(7)
		_: pass
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, screen: Control) -> void:
	match option.name:
		"Open":
			var PickToolUI: Control = Game.onCreatePickToolUI(Helper.getFofInfoID(ToolInfo, 7), screen)
			PickToolUI.selected.connect(onOpenStaffSelected.bind(option, screen))
			return
		"Force":
			var roll: bool = Random.rollFloat(FORCE_OPEN_CHANCE)
			if !roll: onContinueToNextPageForce("ForceFailPage"); return
			onCreateRewardsUI("ForceSuccessPage", screen)
			return
		"Admire":
			Game.save_file.onUpdateShillings(ADMIRE_SHILLINGS)
	onContinueToNextPage(option)

func onCreateRewardsUI(page_title: String, screen: Control) -> void:
	var RewardsUI: Control = Game.onCreateRewardsUIScreen(rewards, screen)
	rewards_page_title = page_title
	RewardsUI.rewards_finished.connect(onContinueToNextPageForce.bind(page_title))

func onOpenStaffSelected(Tool: ToolGD, Card: CardGD = null, option: EncounterOptionDatastore = null, screen: Control = null) -> void:
	Tool.onClear()
	if Card != null: Card.onRemoveTool()
	onCreateRewardsUI(option.page_title, screen)
	onContinueToNextPage(option)

func onSave() -> SavedDataEncounter:
	rewards.onSave()
	ability_save['rewards'] = rewards
	ability_save['rewards_page_title'] = rewards_page_title
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	if rewards != null:
		rewards.setInfo(self)
		rewards.onLoad()
