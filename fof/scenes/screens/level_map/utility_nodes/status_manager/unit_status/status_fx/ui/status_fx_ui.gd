extends Control
signal mouse_in_ui
signal highlight_unit

@onready var IconButton: TextureButton = $IconButton

var HighlightUnit: UnitGD
var status_fx: StatusFXGD
func onIsMouseInUI(x: bool) -> void:
	mouse_state = x
	mouse_in_ui.emit(x)
	
	if x: onCreateTooltip()
	else: onRemoveTooltip()
	
func setInfo(_status_fx: StatusFXGD) -> void:
	status_fx = _status_fx
	IconButton.texture_normal = status_fx.info.texture
	setHighlightUnit(status_fx.HighlightUnit)

func setHighlightUnit(Unit: UnitGD) -> void: HighlightUnit = Unit

#region Tooltip
var mouse_state: bool = false
const TOOLTIP_DELAY: float = 0.4
var tooltip: Control
func onCreateTooltip() -> void:
	await get_tree().create_timer(TOOLTIP_DELAY).timeout
	if mouse_state and tooltip == null:
		tooltip = preload("res://scenes/screens/level_ui/base_tooltip/base_tooltip.tscn").instantiate()
		add_child(tooltip)
		tooltip.setPosition()
		tooltip.setInfo(status_fx.getTooltip())
		
func onRemoveTooltip() -> void:
	if tooltip != null: tooltip.queue_free()

func _process(_delta: float) -> void:
	if tooltip != null: tooltip.setPosition()
	
#endregion
func _on_icon_button_pressed():
	highlight_unit.emit(status_fx)
