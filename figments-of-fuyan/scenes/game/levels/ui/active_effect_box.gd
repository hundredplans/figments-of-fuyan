extends Control

signal pressed
signal mouse_in_ui

@onready var Btn: Button = %Button
@onready var NameLabel: Label = %NameLabel
@onready var DescriptionLabel: FancyTextLabel = %DescriptionLabel
@onready var ChargesLabel: Label = %ChargesLabel

var active_effect: ActiveEffectDatastore
func setInfo(_active_effect: ActiveEffectDatastore) -> void:
	active_effect = _active_effect
	NameLabel.text = active_effect.getName()
	DescriptionLabel.setText(active_effect.getDescription())
	
	var charges: int = active_effect.getCharges()
	var max_charges: int = active_effect.getMaxCharges()
	ChargesLabel.text = "Charges: " + ("∞" if max_charges == -1 else (str(charges) + "/" + str(max_charges)))
	
	if active_effect.owner is ToolGD: Btn.modulate = Color(0, 1, 1)
	elif active_effect.owner is ObjectGD: Btn.modulate = Color(1, 0, 0)
	
	setDisabled()
	
func setDisabled() -> void:
	var disabled: bool = active_effect.used or active_effect.getCharges() == 0 or is_action_lock or\
	(active_effect.owner is CardGD and ((active_effect.owner.turn_state != Game.TurnStates.INACTIVE or active_effect.owner.isMobile()) or active_effect.owner.isEnemy(0)))
	
	Btn.disabled = disabled
	modulate = HOVERED_OR_BASE if !disabled else Color(0.6, 0.6, 0.6, 1)

var HOVERED_OR_BASE := Color(1, 1, 1, 1)
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	HOVERED_OR_BASE = Color(1, 1, 1, 1) if !state else Color(0.8, 0.8, 0.8, 1)
	setDisabled()
	
var is_action_lock: bool
func onUpdateActionLock(state: bool) -> void:
	is_action_lock = state
	setDisabled()
	
func onPressed() -> void:
	pressed.emit(active_effect)
