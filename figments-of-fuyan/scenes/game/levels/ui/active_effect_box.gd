extends Control

signal pressed
signal mouse_in_ui

@onready var Btn: Button = %Button
@onready var NameLabel: Label = %NameLabel
@onready var DescriptionLabel: FancyTextLabel = %DescriptionLabel

@onready var ChargesLabelCharges: Label = %ChargesLabelCharges
@onready var ChargesLabelMaxCharges: Label = %ChargesLabelMaxCharges
@onready var ChargesLabelSlash: Label = %ChargesLabelSlash

var active_effect: ActiveEffectDatastore
var Card: CardGD

func setInfo(_active_effect: ActiveEffectDatastore, _Card: CardGD, _is_action_lock: bool) -> void:
	Card = _Card
	active_effect = _active_effect
	is_action_lock = _is_action_lock
	NameLabel.text = active_effect.getName()
	DescriptionLabel.setText(active_effect.getDescription())
	
	active_effect.owner.update_active_effect_description.connect(onUpdateActiveDescription)
	
	var charges: int = active_effect.getCharges()
	var max_charges: int = active_effect.getMaxCharges()
	

	
	if max_charges != -1:
		ChargesLabelCharges.text = str(charges)
		ChargesLabelSlash.text = "/"
		ChargesLabelMaxCharges.text = str(max_charges)
		if charges < max_charges: ChargesLabelCharges.modulate = Color(1, 0, 0)
		if charges > max_charges: ChargesLabelCharges.modulate = Color(0, 1, 0)
	else:
		ChargesLabelCharges.text = "∞"
		ChargesLabelSlash.text = ""
		ChargesLabelMaxCharges.text = ""
	
	if active_effect.owner is ToolGD: Btn.modulate = Color(0, 1, 1)
	elif active_effect.owner is ObjectGD: Btn.modulate = Color(1, 0, 0)
	
	setDisabled()
	
func setDisabled() -> void:
	var is_enemy: bool = Card.isEnemy(0)
	
	Btn.disabled = active_effect.getDefaultDisabled(Card) or is_action_lock or is_enemy
	modulate = HOVERED_OR_BASE if !Btn.disabled else Color(0.6, 0.6, 0.6, 1)

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
	
func onUpdateActiveDescription() -> void:
	DescriptionLabel.setText(active_effect.getDescription())
