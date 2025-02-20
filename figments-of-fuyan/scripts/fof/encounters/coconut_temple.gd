extends EncounterGD

const FORCE_OPEN_CHANCE: float = 0.15
const ADMIRE_SHILLINGS: int = 10
const OPEN_SHILLINGS: int = 50
var rewards_page_title: String
var rewards: Rewards

func onFirstEntered(screen: Control) -> void:
	super(screen)
	var change_shillings_wrapper: ActionWrapper = SavedData.onLoadModel(SavedDataActionWrapper.new(), self)
	change_shillings_wrapper.setActions(ChangeShillingsAction.new(OPEN_SHILLINGS))
	
	var Boon: BoonGD = SavedData.onLoadModel(Random.getRandomFofByOdds(BoonInfo), self)
	var Tool: ToolGD = SavedData.onLoadModel(Random.getRandomFofByOdds(ToolInfo), self)
	rewards = Rewards.new([change_shillings_wrapper, Boon, Tool])
	
func onEntered(screen: Control) -> void:
	super(screen)
	if rewards.taken_items.is_empty() or rewards.items.is_empty(): return
	onCreateRewardsUI("OpenPage", screen)
	
func canShowUp() -> bool:
	return true
	
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
			onPushAction(ChangeShillingsAction.new(ADMIRE_SHILLINGS))
			var tool_data: SavedDataTool = Game.getRandomFofInRarity(ToolInfo, Game.Rarities.COMMON)
			var Tool: ToolGD = SavedData.onLoadModel(tool_data, self)
			Game.onCreateToolPickedUpUI(Tool, false, screen)
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
