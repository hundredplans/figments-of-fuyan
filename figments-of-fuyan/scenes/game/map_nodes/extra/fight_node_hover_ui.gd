extends HoverUI

@export var UIBoxPacked: PackedScene
@onready var UIBoxParent: Control = %UIBoxParent

@onready var TotalNumberLabel: Label = %TotalNumberLabel
@onready var LevelNameLabel: Label = %LevelNameLabel
@onready var LocationLabel: Label = %LocationLabel
@onready var ExtraLabelManager: Container = %ExtraLabelManager

func setInfo(map_node: MapNodeGD) -> void:
	var area: AreaGD = Game.getArea()
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node.level_info.id)
	
	LevelNameLabel.text = level_info.name
	LevelNameLabel.modulate = Game.getArea().getInfo().area_color
	LocationLabel.text = LocationLabel.text % [area.getWorldDifficulty(), clamp(map_node.map_location.progress, 0, 10)]
	
	for card_data: SavedDataCard in map_node.level_preview.getCardDatas():
		onAddUIBox(card_data)
		
	ExtraLabelManager.get_parent().move_child(ExtraLabelManager, ExtraLabelManager.get_parent().get_child_count())
	TotalNumberLabel.text = TotalNumberLabel.text % [map_node.level_preview.getTotalAmount()]
	
	pivot_offset = Vector2(105, 120)
	setMouseCenter(get_viewport().get_mouse_position())
	
func setMouseCenter(mouse_position: Vector2) -> void:
	global_position = mouse_position - pivot_offset
	
func onAddUIBox(card_data: SavedDataCard) -> Control:
	var UIBox: Control = UIBoxPacked.instantiate()
	
	UIBoxParent.add_child(UIBox)
	UIBox.setInfo(card_data)
	return UIBox
