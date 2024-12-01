extends EncounterGD

const ACCEPT_OPTION_SHILLINGS: int = 12
const SLEIGHT_OF_HAND_SHILLINGS: int = 12

func canShowUp() -> bool:
	return anyRequirementMet()

func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		"Accept": return Game.save_file.getShillings() >= ACCEPT_OPTION_SHILLINGS
		"Sleight of Hand":
			return Game.save_file.getShillings() >= SLEIGHT_OF_HAND_SHILLINGS and Game.isIDInDeck(7)
	return true

func onOptionPressed(option: EncounterOptionDatastore, screen: Control) -> void:
	match option.name:
		"Accept":
			var Tool: ToolGD = SavedData.onLoadModel(SavedDataTool.new(13, true), self)
			var ToolPickedUpUI: Control = Game.onCreateToolPickedUpUI(Tool, false, screen)
			ToolPickedUpUI.taken.connect(onToolAccepted.bind(option))
			return
		"Sleight of Hand":
			Game.save_file.onUpdateShillings(-SLEIGHT_OF_HAND_SHILLINGS)
			var tool_data: SavedDataTool = Game.getRandomFofInRarity(ToolInfo, Game.Rarities.COMMON)
			var Tool: ToolGD = SavedData.onLoadModel(tool_data, self)
			Game.onCreateToolPickedUpUI(Tool, false, screen)
		"Reject":
			var Boon: BoonGD = SavedData.onLoadModel(SavedDataBoon.new(9, true), self)
			Game.save_file.onAddBoon(Boon)
	onContinueToNextPage(option)

func onToolAccepted(_Tool: ToolGD, option: EncounterOptionDatastore) -> void:
	Game.save_file.onUpdateShillings(-ACCEPT_OPTION_SHILLINGS)
	onContinueToNextPage(option)
