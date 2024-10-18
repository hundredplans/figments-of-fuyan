extends Control

@export var UIBoxPacked: PackedScene
@onready var LevelLabel: Label = %LevelLabel
@onready var UIBoxParent: Control = %UIBoxParent

const UNIT_BOXES_DISPLAYED: int = 3

func setInfo(map_node: MapNodeGD, area: AreaGD) -> void:
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node.level_info.id)
	LevelLabel.text = str(area.getWorld()) + "-" + str(map_node.map_location.progress) + ": " + str(level_info.name)
	
	var valid_spawns: Array = map_node.spawn_ids
	for i in range(UNIT_BOXES_DISPLAYED):
		if valid_spawns.size() > i:
			var UIBox: Control = UIBoxPacked.instantiate()
			var card_info: CardInfo = Helper.getFofInfoID(CardInfo, valid_spawns[i])
			UIBoxParent.add_child(UIBox)
			UIBox.setInfo(card_info)
			
	match map_node.get_script():
		BossFightNodeGD: theme_type_variation = "RedPanelContainer"
		MinibossFightNodeGD: theme_type_variation = "PurplePanelContainer"
		ChiefFightNodeGD: theme_type_variation = "YellowPanelContainer"
		
		EliteFightNodeGD: theme_type_variation = "WhitePanelContainer"
		EliteChiefFightNodeGD: theme_type_variation = "WhitePanelContainer"
	
func setMouseCenter(mouse_position: Vector2) -> void:
	position = mouse_position - (size / 2) - Vector2(0, 100)
