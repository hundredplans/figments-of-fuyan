extends Control

signal update_stash_screen
signal mouse_in_ui

const SCALE_MAX: float = 1.1
const SCALE_SPEED: float = 0.25

const SHILLING_SPIN: float = PI / 4
const SHILLING_SPIN_TIME: float = 2.0

@onready var LevelTxRect: TextureRect = %LevelTxRect
@onready var LevelNameLabel: Label = %LevelNameLabel

@onready var BoonBox: Control = %BoonBox
@onready var ShillingsLabel: Label = %ShillingsLabel
@onready var StashAmountLabel: Label = %StashAmountLabel
@onready var StashButton: DefaultButton = %StashButton
@onready var ShillingTxRect: TextureRect = %ShillingTxRect

@onready var BoonBoxContainer: DefaultControl = %BoonBoxContainer
@onready var ExtraInfoManager: Control = %ExtraInfoManager
@export var show_card_amount_label: bool = true

var is_game_ended: bool
var is_action_lock: bool
var is_mouse_in_ui: bool

func _ready() -> void:
	ShillingTxRect.rotation -= (SHILLING_SPIN / 2)
	StashAmountLabel.visible = show_card_amount_label
	onSpinShillings()

func getBoonBox() -> Control:
	return BoonBox

func onUpdateStashAmountLabel() -> void:
	var deck_amount: String = str(Game.getSaveFile().getUsedDeckSlotCount())
	var deck_limit: String = str(Game.getSaveFile().getDeckLimit())
	StashAmountLabel.text = deck_amount + "/" + deck_limit

func onUpdateShillings() -> void:
	ShillingsLabel.text = str(Game.getSaveFile().getShillings())

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	
func onStashButtonPressed() -> void:
	update_stash_screen.emit()

var ScaleStashButtonTween: Tween
func onStashButtonMouseInUI(state: bool) -> void:
	var target_value: float = (SCALE_MAX if state else 1.0) - StashButton.scale.x
	if ScaleStashButtonTween: ScaleStashButtonTween.kill()
	ScaleStashButtonTween = create_tween()
	ScaleStashButtonTween.tween_property(StashButton, "scale", Vector2(target_value, target_value), SCALE_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)

func onSpinShillings(direction: int = 1) -> void:
	var tween := create_tween()
	tween.tween_property(ShillingTxRect, "rotation", SHILLING_SPIN * direction, SHILLING_SPIN_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	direction *= -1
	tween.finished.connect(onSpinShillings.bind(direction))

func setZIndex(_z_index: int) -> void:
	StashButton.z_index = _z_index
	ExtraInfoManager.z_index = _z_index

func onFadeBackgroundNodes(end_value: float, condition: String = "", change_mouse_filter: bool = false) -> void:
	var nodes: Array = []
	match condition:
		"OnlyBoonBox": nodes = [BoonBox]
		"NoBoonBox": nodes = [StashButton, ExtraInfoManager]
		_: nodes = [StashButton, ExtraInfoManager, BoonBox]
	for node: Control in nodes:
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", end_value, Game.FADE_TIME)
		
		if node == StashButton and change_mouse_filter:
			node.setMouseFilter(Control.MOUSE_FILTER_IGNORE if end_value <= 0.01 else Control.MOUSE_FILTER_STOP)

func getStashButton() -> Control: return StashButton

func setLevelName(level_name: String, level_color: Color, area_id: int) -> void:
	LevelTxRect.visible = true
	LevelNameLabel.text = level_name
	LevelNameLabel.modulate = level_color
	LevelTxRect.texture = Helper.getFofInfoID(AreaInfo, area_id).getAreaIcon()

func setActionLock(state: bool) -> void:
	is_action_lock = state
	onUpdateStashButtonDisabled()
	
func setGameEnded(state: bool) -> void:
	is_game_ended = state
	onUpdateStashButtonDisabled()
	
var FadeStashTween: Tween
func onFadeStashButton(fade_out: bool) -> void:
	StashButton.onFade(!fade_out)
	
func onStashInLevel(fade_in: bool) -> void:
	for node: Control in [ExtraInfoManager, BoonBoxContainer]:
		node.onFade(fade_in)

func onUpdateStashButtonDisabled() -> void:
	StashButton.setDisabled(is_action_lock and !is_game_ended)
