extends HoverUI

@export var UIBoxPacked: PackedScene
@onready var LevelLabel: Label = %LevelLabel
@onready var UIBoxParent: Control = %UIBoxParent
@onready var TotalNumberManager: Control = %TotalNumberManager
@onready var TotalNumberLabel: Label = %TotalNumberLabel

const CHIEF_UI_BOX_SEPERATION: int = 30

func setInfo(map_node: MapNodeGD) -> void:
	var area: AreaGD = Game.getArea()
	if area.getProgress() < 5 and map_node.map_location.progress > 5: queue_free(); return
	
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node.level_info.id)
	
	LevelLabel.text = str(area.getWorldDifficulty()) + "-" + str(clamp(map_node.map_location.progress, 0, 10)) + ": " + str(level_info.name)
	
	var chief_data: SavedDataCard = map_node.level_preview.chief_data
	for card_data: SavedDataCard in map_node.level_preview.card_datas:
		onAddUIBox(card_data)
			
	if chief_data != null:
		var UIBox: Control = onAddUIBox(chief_data)
		var filler := Control.new()
		filler.custom_minimum_size.x = CHIEF_UI_BOX_SEPERATION
		UIBoxParent.add_child(filler)
		UIBoxParent.move_child(filler, 0)
		UIBoxParent.move_child(UIBox, 0)
			
	UIBoxParent.move_child(TotalNumberManager, UIBoxParent.get_child_count())
	TotalNumberLabel.text = str(map_node.level_preview.total_amount) + "x	"
	
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
