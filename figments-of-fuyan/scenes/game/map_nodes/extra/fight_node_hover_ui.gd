extends HoverUI

@onready var TopLabelsManager: Control = %TopLabelsManager

@export var UIBoxPacked: PackedScene
@onready var UIBoxParent: Control = %UIBoxParent

@onready var TotalNumberLabel: Label = %TotalNumberLabel
@onready var LevelNameLabel: Label = %LevelNameLabel
@onready var LocationLabel: Label = %LocationLabel
@onready var ExtraLabelManager: Container = %ExtraLabelManager

@onready var FightTypeLabel: Label = %FightTypeLabel
@onready var FightTypeTx: TextureRect = %FightTypeTx

@export var regular_fight_text: String
@export var elite_fight_text: String

@export var regular_fight_tx: Texture2D
@export var elite_fight_tx: Texture2D

@export var regular_fight_color: Color
@export var elite_fight_color: Color

const TIMER_TIME: float = 1.5

func setInfo(map_node: MapNodeGD) -> void:
	var area: AreaGD = Game.getArea()
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node.level_info.id)
	
	LevelNameLabel.text = level_info.name
	LevelNameLabel.modulate = Game.getArea().getInfo().area_color
	LocationLabel.text = LocationLabel.text % [area.getWorldDifficulty(), clamp(map_node.map_location.progress, 0, 10)]
	
	if map_node is EliteFightNodeGD:
		onAddUIBox(null, true)
	
	for card_data: SavedDataCard in map_node.level_preview.getCardDatas():
		onAddUIBox(card_data)
		
	ExtraLabelManager.get_parent().move_child(ExtraLabelManager, ExtraLabelManager.get_parent().get_child_count())
	TotalNumberLabel.text = TotalNumberLabel.text % [map_node.level_preview.getTotalAmount()]
	
	pivot_offset = Vector2(105, 120)
	setMouseCenter(get_viewport().get_mouse_position())
	
	var fight_type_text: String = regular_fight_text
	var fight_type_color: Color = regular_fight_color
	var fight_type_texture: Texture2D = regular_fight_tx
	
	if map_node is EliteFightNodeGD:
		fight_type_text = elite_fight_text
		fight_type_color = elite_fight_color
		fight_type_texture = elite_fight_tx
		
	FightTypeLabel.text = fight_type_text
	FightTypeLabel.modulate = fight_type_color
	FightTypeTx.texture = fight_type_texture
	onTimer()
	
func onTimer() -> void:
	await get_tree().create_timer(TIMER_TIME).timeout
	FightTypeTx.flip_h = !FightTypeTx.flip_h
	onTimer()
	
func setMouseCenter(mouse_position: Vector2) -> void:
	global_position = mouse_position - pivot_offset
	
func onAddUIBox(card_data: SavedDataCard, is_chief: bool = false) -> Control:
	var UIBox: Control = UIBoxPacked.instantiate()
	
	UIBoxParent.add_child(UIBox)
	if !is_chief: UIBox.setInfo(card_data)
	else: UIBox.setChief()
	
	return UIBox
