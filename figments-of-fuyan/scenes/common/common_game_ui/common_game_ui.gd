extends Control

signal create_stash_screen
signal mouse_in_ui

const SCALE_MAX: float = 1.1
const SCALE_SPEED: float = 0.25

@onready var BoonBox: Control = %BoonBox
@onready var ShillingsLabel: Label = %ShillingsLabel
@onready var StashAmountLabel: Label = %StashAmountLabel
@onready var StashButton: TextureButton = %StashButton

var is_mouse_in_ui: bool

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
	create_stash_screen.emit()

var ScaleStashButtonTween: Tween
func onStashButtonMouseInUI(state: bool) -> void:
	var target_value: float = (SCALE_MAX if state else 1.0) - StashButton.scale.x
	if ScaleStashButtonTween: ScaleStashButtonTween.kill()
	ScaleStashButtonTween = create_tween()
	ScaleStashButtonTween.tween_property(StashButton, "scale", Vector2(target_value, target_value), SCALE_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
