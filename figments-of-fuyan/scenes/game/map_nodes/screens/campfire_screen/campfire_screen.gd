extends MapNodeScreen

@onready var CampfireRewards: Control = %CampfireRewards
@onready var TravelledLabel: FancyTextLabel = %TravelledLabel

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, _map_node: MapNodeGD) -> void:
	super(_save_file, _area, _World, _UI, _map_node)
	var travelled: int = Game.getHolyTravelledAmount()
	TravelledLabel.setText("You have travelled the [color=navajo_white]Holy Path[/color] " + str(travelled) + " times")
	for i in range(CampfireRewards.get_child_count()):
		var CampfireRewardNode: Control = CampfireRewards.get_child(i)
		CampfireRewardNode.setInfo(map_node.campfire_reward_taken[i])
		CampfireRewardNode.pressed.connect(onCampfireRewardPressed.bind(i))

func onDimBackground() -> bool:
	return true

func onChoiceButtonPressed(identifier: String) -> void:
	var trait_data: SavedDataTrait
	match identifier:
		"Armor": trait_data = SavedDataArmor.new(1, true, 0); trait_data.armor = 1
		"Mobile": trait_data = SavedDataTrait.new(3, true)
		"Resist": trait_data = SavedDataTrait.new(4, true)
		"Nothing": onFinished(); return

	var DeckScreen: Control = Game.onCreateDeckScreen(self, true, 1, onFilterCardsByTraitData.bind(trait_data))
	DeckScreen.selected.connect(onDeckScreenSelected.bind(trait_data))

func onFilterCardsByTraitData(CardUI: Control, trait_data: SavedDataTrait) -> bool:
	return CardUI.Card.getOverworldTraitByID(trait_data.id) != null

func onDeckScreenSelected(Card: CardGD, trait_data: SavedDataTrait) -> void:
	Card.onAddOverworldTrait(OverworldTrait.new(trait_data, OverworldTrait.AddedBy.NULL))
	onFinished()

func onCampfireRewardPressed(reward_node: Control, reward_info: FofInfo, index: int) -> void:
	map_node.campfire_reward_taken[index] = true
	if reward_info is CardInfo:
		var card_data: SavedDataCard = Game.onCreateBaseCard(reward_info.id, false)
		var Card: CardGD = SavedData.onLoadModel(card_data, Game.getSaveFile())
		map_node.onPushAction(AddToDeckAction.new(Card))
		reward_node.onRewardClaimed()
	elif reward_info is ToolInfo:
		var Tool: ToolGD = SavedData.onLoadModel(SavedDataTool.new(reward_info.id, true), map_node)
		var ToolPickedUpUI: Control = Game.onCreateToolPickedUpUI(Tool, true, self)
		ToolPickedUpUI.taken.connect(func(_x: Variant): reward_node.onRewardClaimed())

func onFinished() -> void:
	finished.emit()
	queue_free()

func onLeaveButtonPressed() -> void:
	onFinished()
