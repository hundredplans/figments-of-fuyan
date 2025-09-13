extends Control

signal update_stash_screen
signal mouse_in_ui

const SCALE_MAX: float = 1.1
const SCALE_SPEED: float = 0.25

const SHILLING_SPIN: float = PI / 4
const SHILLING_SPIN_TIME: float = 2.0

@onready var BoonBox: Control = %BoonBox
@onready var ShillingsLabel: Label = %ShillingsLabel
@onready var StashAmountLabel: Label = %StashAmountLabel
@onready var StashButton: TextureButton = %StashButton
@onready var ShillingTxRect: TextureRect = %ShillingTxRect

@onready var ExtraInfoManager: Control = %ExtraInfoManager

var is_mouse_in_ui: bool

func _ready() -> void:
	ShillingTxRect.rotation -= (SHILLING_SPIN / 2)
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

func onFadeBackgroundNodes(end_value: float, only_boons: bool) -> void:
	var nodes: Array = [StashButton, ExtraInfoManager, BoonBox] if !only_boons else [BoonBox] 
	for node: Control in nodes:
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", end_value, Game.FADE_TIME)
