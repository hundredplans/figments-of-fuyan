extends HoverUI

@export var FofUIBoxPacked: PackedScene
@onready var FofUIControl: Control = %FofUIControl
@onready var BossNameLabel: Label = %BossNameLabel

@onready var TypeLabel: Label = %TypeLabel
@onready var TypeTx: TextureRect = %TypeTx

@export var BOSS_TEXTURE: Texture2D
@export var MINIBOSS_TEXTURE: Texture2D

@export var BOSS_COLOR: Color
@export var MINIBOSS_COLOR: Color

func setInfo(map_node: MapNodeGD) -> void:
	var FofUIBox: Control = FofUIBoxPacked.instantiate()
	FofUIBox.disable_tooltip = true
	FofUIControl.add_child(FofUIBox)
	FofUIBox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var boss_data := SavedDataCard.new(map_node.boss_id)
	FofUIBox.setInfo(boss_data)
	FofUIBox.scale = Vector2(2, 2)
	
	var boss_info: EpicCardInfo = Helper.getFofInfoID(EpicCardInfo, boss_data.id)
	BossNameLabel.text = boss_info.name
	
	var theme_path: String = ""
	
	var type_text: String
	var type_tx: Texture2D
	var type_color: Color
	
	if map_node is MinibossFightNodeGD:
		theme_path = "PurplePanelContainer"
		BossNameLabel.modulate = Game.getRarityColor(Game.Rarities.MINIBOSS)
		type_text = "Miniboss"
		type_tx = MINIBOSS_TEXTURE
		type_color = MINIBOSS_COLOR
	elif map_node is BossFightNodeGD:
		theme_path = "RedPanelContainer"
		BossNameLabel.modulate = Game.getRarityColor(Game.Rarities.BOSS)
		type_text = "Boss"
		type_tx = BOSS_TEXTURE
		type_color = BOSS_COLOR
	
	theme_type_variation = theme_path
	TypeLabel.text = type_text
	TypeTx.texture = type_tx
	TypeLabel.modulate = type_color
	
	setMouseCenter(get_viewport().get_mouse_position())
	
	
