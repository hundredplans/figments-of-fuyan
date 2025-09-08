extends EncounterSubscreen

@export var JUNK_MAN_MILESTONE_TX: Texture2D

@onready var JunkManBase: Control = %JunkManBase
@onready var InfoLabel: Label = %InfoLabel
@onready var FillBar: Control = %FillBar
@onready var FillBarOutline: Control = %FillBarOutline
@onready var EncounterMainUI: Control = %EncounterMainUI
@onready var RewardParent: Control = %RewardParent

@export var REWARD_CARD_POSITION := Vector2(1204, 140)
@export var REWARD_BOON_POSITION := Vector2(1250, 375)
@export var REWARD_TOOL_POSITION := Vector2(1250, 375)

const INFO_LABEL_TEXT: String = "Sell items to fill up the bar and gain a reward: %s/%s"
const REWARD_TOOL_SIZE_SCALE: int = 4
const REWARD_BOON_SIZE_SCALE: int = 2

var RewardItem: FofGD
var tbc: TbcUI

func getMinimapFadeNodes() -> Array: return [JunkManBase, RewardParent, InfoLabel]
func getStashFadeNodes() -> Array: return [JunkManBase, RewardParent, InfoLabel]

func setInfo(_map_node: MapNodeGD) -> void:
	super(_map_node)
		
	var bitmap_frames: Array[BitMap] = map_node.getEncounterDatastore().getBitmapFrames()
	var frames: Array[Texture2D] = map_node.getEncounterDatastore().getFrames()
	EncounterMainUI.setInfo(null, frames, bitmap_frames)
	onUpdateBaseSprite()
	
	FillBar.onUpdateColors(map_node.getFillBarBackgroundColor(), map_node.getFillBarForegroundColor())
	FillBar.setMaxValue(map_node.getMaxValue())
	FillBar.setValue(map_node.getJunkManValue())
	onUpdateRewardItem()
	onUpdateInfoLabel()

func onStashScreenExitStart() -> void:
	super()
	FillBar.setValue(map_node.getJunkManValue())
	onUpdateBaseSprite()
	onUpdateRewardItem()
	onUpdateInfoLabel()
	EncounterMainUI.setDisableUpdateModulate(false)
	
func onStashScreenStart() -> void:
	super()

func _on_encounter_main_ui_pressed() -> void:
	EncounterMainUI.setDisableUpdateModulate(true)
	create_stash_screen.emit(null)
	
func onUpdateBaseSprite() -> void:
	var base_sprite: Texture2D
	if map_node.getRewardData() == null: base_sprite = map_node.getEncounterDatastore().getBaseSprite()
	else: base_sprite = JUNK_MAN_MILESTONE_TX
	EncounterMainUI.setBaseSprite(base_sprite)

func onUpdateRewardItem() -> void:
	if RewardItem != null: RewardItem.onClear()
	if tbc != null: tbc.queue_free()
	if map_node.getRewardData() != null:
		RewardItem = SavedData.onLoadModel(map_node.getRewardData(), Game.getSaveFile())
		tbc = RewardItem.onCreateTbcUI(RewardParent, true, false, true)
		tbc.pressed.connect(onRewardPressed)
		var pos: Vector2
		match RewardItem.info.getFofName():
			"Card": 
				pos = REWARD_CARD_POSITION
			"Boon":
				pos = REWARD_BOON_POSITION
				tbc.setSizeScale(REWARD_BOON_SIZE_SCALE)
			"Tool":
				pos = REWARD_TOOL_POSITION
				tbc.setSizeScale(REWARD_TOOL_SIZE_SCALE)
		tbc.global_position = pos
		
func onRewardPressed(_tbc: TbcUI) -> void:
	var item: FofGD = tbc.getItem()
	if item is ToolGD:
		create_stash_screen.emit(tbc)
		return
	onRewardCollected(item)
		
func onFinished() -> void:
	if RewardItem != null: RewardItem.onClear()

func onActiveToolAdded(CardUI: TbcUI) -> void:
	onRewardCollected(CardUI.getItem().getTool())

func onRewardCollected(item: FofGD) -> void:
	tbc.queue_free()
	map_node.onRewardCollected(item)
	onUpdateBaseSprite()

func onUpdateInfoLabel() -> void:
	var value: int = map_node.getJunkManValue()
	var max_value: int = map_node.getMaxValue()
	InfoLabel.text = INFO_LABEL_TEXT % [value, max_value]
