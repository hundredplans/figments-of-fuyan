extends Control

@export var UIBoxPacked: PackedScene
@onready var LevelLabel: Label = %LevelLabel
@onready var UIBoxParent: Control = %UIBoxParent
func _process(_delta: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: queue_free()

func setInfo(map_node: MapNodeGD, area: AreaGD) -> void:
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node.level_info.id)
	LevelLabel.text = str(area.getWorldDifficulty()) + "-" + str(map_node.map_location.progress) + ": " + str(level_info.name)
	
	var valid_spawns: Array = map_node.enemy_spawns.duplicate()
	valid_spawns.resize(Game.CARD_REWARD_DEFAULT_AMOUNT)
	valid_spawns = valid_spawns.filter(func(x: SavedDataCard): return x != null and !(x.ascended and Helper.getFofInfoID(CardInfo, x.id).rarity == Game.Rarities.EXALT))
	var valid_infos: Dictionary = {}
	for saved_data_card in valid_spawns:
		valid_infos[saved_data_card] = Helper.getFofInfoID(CardInfo, saved_data_card.id)
	
	valid_spawns.sort_custom(func(x: SavedDataCard, y: SavedDataCard): return valid_infos[x].rarity > valid_infos[y].rarity)
	valid_spawns.sort_custom(func(x: SavedDataCard, y: SavedDataCard): return valid_infos[x].energy > valid_infos[y].energy)
	
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
		EliteFightNodeGD: theme_type_variation = "YellowPanelContainer"
	
func setMouseCenter(mouse_position: Vector2) -> void:
	position = mouse_position - (size / 2) - Vector2(0, 100)
