extends Control

@export var UIBoxPacked: PackedScene
@onready var LevelLabel: Label = %LevelLabel
@onready var UIBoxParent: Control = %UIBoxParent

func setInfo(map_node: MapNodeGD, area: AreaGD) -> void:
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node.level_info.id)
	LevelLabel.text = str(area.getWorldDifficulty()) + "-" + str(map_node.map_location.progress) + ": " + str(level_info.name)
	
	var valid_spawns: Array = map_node.enemy_spawns
	valid_spawns.resize(Game.CARD_REWARD_DEFAULT_AMOUNT)
	valid_spawns = valid_spawns.filter(func(x: SavedDataCard): return x != null)
	
	for card_data in valid_spawns:
		var UIBox: Control = UIBoxPacked.instantiate()
		
		var card_info: CardInfo = Helper.getFofInfoID(CardInfo, card_data.id)
		
		var tool_data: SavedDataTool = card_data.tool_data
		var tool_info: ToolInfo = null if tool_data == null else Helper.getFofInfoID(ToolInfo, tool_data.id)
		
		UIBoxParent.add_child(UIBox)
		UIBox.setInfo(card_info, card_data, tool_info, tool_data)
			
	match map_node.get_script():
		BossFightNodeGD: theme_type_variation = "RedPanelContainer"
		MinibossFightNodeGD: theme_type_variation = "PurplePanelContainer"
		ChiefFightNodeGD: theme_type_variation = "WhitePanelContainer"
		
		EliteFightNodeGD: theme_type_variation = "YellowPanelContainer"
		EliteChiefFightNodeGD: theme_type_variation = "WhitePanelContainer"
	
func setMouseCenter(mouse_position: Vector2) -> void:
	position = mouse_position - (size / 2) - Vector2(0, 100)
