extends HoverUI

@export var UIBoxPacked: PackedScene
@onready var LevelLabel: Label = %LevelLabel
@onready var UIBoxParent: Control = %UIBoxParent
@onready var TotalNumberManager: Control = %TotalNumberManager
@onready var TotalNumberLabel: Label = %TotalNumberLabel

const CHIEF_UI_BOX_SEPERATION: int = 30

func setInfo(map_node: MapNodeGD) -> void:
	var area: AreaGD = Game.getArea()
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node.level_info.id)
	
	LevelLabel.text = str(area.getWorldDifficulty()) + "-" + str(clamp(map_node.map_location.progress, 0, 10)) + ": " + str(level_info.name)
	
	for card_data: SavedDataCard in map_node.level_preview.getCardDatas():
		onAddUIBox(card_data)
			
	UIBoxParent.move_child(TotalNumberManager, UIBoxParent.get_child_count())
	TotalNumberLabel.text = str(map_node.level_preview.getTotalAmount()) + "x"
	
	match map_node.get_script():
		BossFightNodeGD: theme_type_variation = "RedPanelContainer"
		MinibossFightNodeGD: theme_type_variation = "PurplePanelContainer"
		EliteFightNodeGD: theme_type_variation = "DarkBrownPanelContainer"
		
	setMouseCenter(get_viewport().get_mouse_position())
	
func onAddUIBox(card_data: SavedDataCard) -> Control:
	var UIBox: Control = UIBoxPacked.instantiate()
	
	UIBoxParent.add_child(UIBox)
	UIBox.setInfo(card_data)
	return UIBox
