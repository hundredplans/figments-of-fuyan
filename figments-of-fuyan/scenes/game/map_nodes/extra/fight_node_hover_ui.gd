extends Control

@export var UIBoxPacked: PackedScene
@onready var LevelLabel: Label = %LevelLabel
@onready var UIBoxParent: Control = %UIBoxParent

const CHIEF_UI_BOX_SEPERATION: int = 30

func _process(_delta: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: queue_free()

func setInfo(map_node: MapNodeGD, area: AreaGD) -> void:
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node.level_info.id)
	LevelLabel.text = str(area.getWorldDifficulty()) + "-" + str(map_node.map_location.progress) + ": " + str(level_info.name)
	
	var valid_spawns: Array = map_node.enemy_spawns.duplicate()
	
	var chief_data: SavedDataCard
	if map_node is EliteFightNodeGD:
		chief_data = valid_spawns.pop_back()
		
	valid_spawns.resize(Game.CARD_REWARD_DEFAULT_AMOUNT)
	valid_spawns = valid_spawns.filter(func(x: SavedDataCard): return x != null)
	
	var valid_infos: Dictionary = {}
	for saved_data_card in valid_spawns:
		valid_infos[saved_data_card] = Helper.getFofInfoID(CardInfo, saved_data_card.id)
	
	valid_spawns.sort_custom(func(x: SavedDataCard, y: SavedDataCard): return valid_infos[x].rarity > valid_infos[y].rarity)
	valid_spawns.sort_custom(func(x: SavedDataCard, y: SavedDataCard): return valid_infos[x].energy > valid_infos[y].energy)
	
	for card_data in valid_spawns:
		onAddUIBox(card_data)
			
	if chief_data != null:
		var UIBox: Control = onAddUIBox(chief_data)
		var filler := Control.new()
		filler.custom_minimum_size.x = CHIEF_UI_BOX_SEPERATION
		UIBoxParent.add_child(filler)
		UIBoxParent.move_child(filler, 0)
		UIBoxParent.move_child(UIBox, 0)
			
	match map_node.get_script():
		BossFightNodeGD: theme_type_variation = "RedPanelContainer"
		MinibossFightNodeGD: theme_type_variation = "PurplePanelContainer"
		EliteFightNodeGD: theme_type_variation = "DarkBrownPanelContainer"
	
func onAddUIBox(card_data: SavedDataCard) -> Control:
	var UIBox: Control = UIBoxPacked.instantiate()
	var card_info: CardInfo = Helper.getFofInfoID(CardInfo, card_data.id)
	var has_tool: bool = card_data.tool_data != null
	
	UIBoxParent.add_child(UIBox)
	UIBox.setInfo(card_info, card_data, has_tool)
	return UIBox
	
func setMouseCenter(mouse_position: Vector2) -> void:
	position = mouse_position - (size / 2) - Vector2(0, 100)
