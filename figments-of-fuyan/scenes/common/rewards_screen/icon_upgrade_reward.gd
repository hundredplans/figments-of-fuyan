extends Control

signal pressed

@onready var TxRect: DefaultButton = %TextureRect
@onready var TextLabel: Label = %Label

var disabled: bool
func setInfo(tx: Texture2D, text: String, _disabled: bool) -> void:
	TxRect.texture = tx
	TextLabel.text = text
	TxRect.pivot_offset = TxRect.size / 2.0
	setDisabled(_disabled)

func onPressed() -> void:
	if disabled: return
	pressed.emit()
	
func setDisabled(state: bool) -> void:
	disabled = state
	TxRect.setDisabled(disabled)
	setMouseFilter(Control.MOUSE_FILTER_IGNORE if disabled else Control.MOUSE_FILTER_STOP)

func onScaleIconUISize(state: bool, instant: bool = false) -> void:
	TxRect.onScaleSize(state, instant)

func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	TxRect.mouse_filter = _mouse_filter
