class_name Purchasable extends Control

signal pressed
@warning_ignore("unused_signal")
signal create_screen

const SOLD_LABEL_PATH: String = "res://scenes/game/map_nodes/screens/shop_screen/sold_label.tscn"
const SCALE_SPEED: float = 0.25
const SCALE_MAX: float = 1.1
const SCALE_MIN: float = 0.9
var DisplayedUI: Control
var price_datastore: PriceDatastore
var disabled: bool

@onready var PriceLabel: Control = %PriceLabel

func setInfo(_price_datastore: PriceDatastore) -> void:
	pivot_offset = (size / 2.0)
	price_datastore = _price_datastore
	position = price_datastore.getPosition()
	
	Game.getSaveFile().update_shillings.connect(onUpdateShillings)
	
	setPriceLabel()
	if price_datastore.bought: setBoughtVisual(true)
	DisplayedUI.mouse_in_ui.connect(onMouseInUI)

func setPriceLabel() -> void:
	PriceLabel.setShillings(price_datastore.price)
	onUpdateShillings()

func onUpdateShillings() -> void:
	var _disabled: bool = price_datastore.bought or price_datastore.price > Game.getSaveFile().getShillings()
	setDisabled(_disabled)

func setDisabled(state: bool) -> void:
	disabled = state
	onUpdateModulate()

func onPressed() -> void:
	if price_datastore.bought: return
	pressed.emit(price_datastore)
	setBoughtVisual(false)
	
func onMouseInUI(state: bool) -> void:
	if disabled: return
	onScaleIconUISize(state)
	onUpdateModulate()

func setBoughtVisual(instant: bool) -> void:
	setDisabled(true)
	var SoldLabel: Label = load(SOLD_LABEL_PATH).instantiate()
	add_child(SoldLabel)
	SoldLabel.position = -(SoldLabel.size / 2.0) + (DisplayedUI.pivot_offset)

var ScaleIconUITween: Tween
func onScaleIconUISize(state: bool) -> void:
	var target_value: float = (SCALE_MAX if state else SCALE_MIN) - scale.x
	if ScaleIconUITween: ScaleIconUITween.kill()
	ScaleIconUITween = create_tween()
	ScaleIconUITween.tween_property(self, "scale", Vector2(target_value, target_value), SCALE_SPEED)\
		.as_relative().set_trans(Tween.TRANS_SINE)

func onUpdateModulate() -> void:
	PriceLabel.modulate = Color(1, 1, 1) if !disabled else Color(0.2, 0.2, 0.2)
	
