class_name TbcUI extends Control

const SPICYRICE_TINY_PATH: String = "res://resources/ui/label_settings/spicyrice_tiny.tres"
const SPICYRICE_MINOR_PATH: String = "res://resources/ui/label_settings/spicyrice_minor.tres"
const SPICYRICE_SMALL_PATH: String = "res://resources/ui/label_settings/spicyrice_small.tres"
const SPICYRICE_LARGE_PATH: String = "res://resources/ui/label_settings/spicyrice_large.tres"
const SPICYRICE_HUGE_PATH: String = "res://resources/ui/label_settings/spicyrice_huge.tres"
const SPICYRICE_MASSIVE_PATH: String = "res://resources/ui/label_settings/spicyrice_massive.tres"

const ROTATION_SPEED_TO_MIDDLE: float = 15.0
const RELATIVE_SIDE_FORCE_DIV: float = 2.5
const TIME_TO_ENABLE_DRAGGING: float = 0.1

const ITEM_GAINED_SPIN_TIME: float = 0.3
const ITEM_GAINED_SPIN_TOTAL_ROTATION: float = (PI / 6)
const ITEM_GAINED_SCALE_OFFSET: float = 0.4
const ITEM_GAINED_INITAL_SCALE_TIME: float = 0.2
const ITEM_GAINED_RECOVERY_SCALE_TIME: float = 0.8

var can_disable_dragging_pressed: bool
var end_drag_on_release: bool = true
var current_mouse_filter: Control.MouseFilter

var is_mouse_in_ui: bool
var disabled: bool
var disable_tooltip: bool
var default_alpha: float = 1.0

var autoscale: bool
var draggable: bool
var is_dragging: bool
var hoverable: bool
var keep_rotation_drag_end: bool

var original_tooltip_state: bool
var original_icon_position: Vector2
var original_icon_rotation: float
var original_mouse_filter: Control.MouseFilter

const SCALE_SPEED: float = 0.25
const SCALE_MAX: float = 1.1
const SCALE_MIN: float = 1.0

signal pressed
signal mouse_in_ui
signal drag_begin
signal drag_end

@onready var ModulateMain: Control = %ModulateMain

#region Abstract
func getItem() -> FofGD: return null
func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	current_mouse_filter = _mouse_filter
#endregion

#region Price Label
var PriceLabel: Control
func onAddPriceLabel(_PriceLabel: Control) -> void:
	PriceLabel = _PriceLabel
	add_child(PriceLabel)
	PriceLabel.position = getPriceLabelPosition()
	
func getPriceLabelPosition() -> Vector2:
	return Vector2.ZERO
	
func onRemovePriceLabel() -> void:
	if PriceLabel != null: PriceLabel.queue_free()
#endregion

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_dragging and !end_drag_on_release and can_disable_dragging_pressed:
		onDragEnd()
	elif Input.is_action_just_pressed("MainInput") and is_mouse_in_ui:
		onPressed()
	elif Input.is_action_just_released("MainInput") and is_dragging and end_drag_on_release:
		onDragEnd()
		
	if is_dragging:
		rotation = lerp_angle(rotation, 0, ROTATION_SPEED_TO_MIDDLE * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		if is_dragging:
			position += event.relative
			rotation_degrees += event.relative.x / RELATIVE_SIDE_FORCE_DIV

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	onUpdateCursorVisual(draggable and is_mouse_in_ui and !disabled)
	
	if is_dragging: return
	mouse_in_ui.emit(state)
	onUpdateModulate()
	
	if !autoscale or disabled: return
	onScaleIconUISize(is_mouse_in_ui, false)

func onUpdateModulate() -> void:
	var color: Color
	if disabled: color = Color(0.2, 0.2, 0.2)
	elif isHoveredColor(): color = Color(0.5, 0.5, 0.5)
	else: color = Color.WHITE
	color.a = default_alpha
	ModulateMain.modulate = color
	
func isHoveredColor() -> bool:
	return is_mouse_in_ui and hoverable or is_dragging

func setDisableTooltip(_disable_tooltip: bool) -> void:
	disable_tooltip = _disable_tooltip

func setDraggable(_draggable: bool) -> void:
	draggable = _draggable
	
func setAutoscale(_autoscale: bool, instant: bool = false, autoset: bool = true) -> void:
	autoscale = _autoscale
	if autoset:
		onScaleIconUISize(is_mouse_in_ui, instant)

func setHoverable(state: bool) -> void:
	hoverable = state
	get_viewport().update_mouse_cursor_state()
	onUpdateModulate()
	
func onDragBegin() -> void:
	Game.is_dragging = true
	is_dragging = true
	original_tooltip_state = disable_tooltip
	original_icon_position = position
	original_icon_rotation = rotation
	disable_tooltip = true
	
	original_mouse_filter = current_mouse_filter
	setMouseFilter(Control.MouseFilter.MOUSE_FILTER_IGNORE)
	
	Game.onMouseInUITooltip(false)
	drag_begin.emit(self)
	
	onUpdateModulate()
	
	await get_tree().process_frame
	var original_global_position: Vector2 = global_position
	top_level = true
	global_position = original_global_position
	get_viewport().update_mouse_cursor_state()
	
	await get_tree().create_timer(TIME_TO_ENABLE_DRAGGING).timeout
	can_disable_dragging_pressed = true
	
func onDragEnd() -> void:
	Game.is_dragging = false
	is_dragging = false
	disable_tooltip = original_tooltip_state
	drag_end.emit(self)
	
	onDragPositionReset()
	onUpdateModulate()
	onDragFinished.call_deferred()

func onDragFinished() -> void:
	setMouseFilter(original_mouse_filter)
	get_viewport().update_mouse_cursor_state()
	onScaleIconUISize(is_mouse_in_ui, true)
	
var ignore_drag_position_reset: bool
func setIgnoreDragPositionReset(_ignore_drag_position_reset: bool) -> void:
	ignore_drag_position_reset = _ignore_drag_position_reset
	
func setKeepRotationDragEnd(state: bool) -> void:
	keep_rotation_drag_end = state
	
func onDragPositionReset() -> void:
	if ignore_drag_position_reset: return
	top_level = false
	position = original_icon_position
	rotation = 0 if !keep_rotation_drag_end else original_icon_rotation
	
func onPressed() -> void:
	if disabled: return
	pressed.emit(self)
	if !draggable: return
	onDragBegin()
	
func onDisableDraggable() -> void:
	draggable = false
	
func setEndDragOnRelease(_end_drag_on_release: bool) -> void:
	end_drag_on_release = _end_drag_on_release

var ScaleIconUITween: Tween
func onScaleIconUISize(state: bool, instant: bool = false) -> void:
	var target_value: float = (SCALE_MAX if state else SCALE_MIN) - scale.x
	if ScaleIconUITween: ScaleIconUITween.kill()
	if !instant:
		ScaleIconUITween = create_tween()
		ScaleIconUITween.tween_property(self, "scale", Vector2(target_value, target_value), SCALE_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
	else: scale += Vector2(target_value, target_value)

func onUseScaleIconUITween(value: float, speed: float) -> void:
	if ScaleIconUITween: ScaleIconUITween.kill()
	ScaleIconUITween = create_tween()
	ScaleIconUITween.tween_property(self, "scale", Vector2(value, value), speed)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	await ScaleIconUITween.finished

func getToolBoonLabelSettings(label_offset: int = 0) -> LabelSettings:
	var label_paths: Array[String] = [SPICYRICE_TINY_PATH, SPICYRICE_SMALL_PATH,\
		SPICYRICE_LARGE_PATH, SPICYRICE_HUGE_PATH, SPICYRICE_HUGE_PATH]
	var nums: Array = [40, 80, 160, 320, 480]
	for i in range(nums.size()): # 40, 80, 160
		if custom_minimum_size.x <= nums[i]:
			return load(label_paths[max(i + label_offset, 0)])
	return null

func getHoverable() -> bool: return hoverable
func getAutoscale() -> bool: return autoscale
func getDraggable() -> bool: return draggable

func setInfo(_item: FofGD, _hoverable: bool = false, _draggable: bool = false, _autoscale: bool = false, _disabled: bool = false) -> void:
	hoverable = _hoverable
	draggable = _draggable
	autoscale = _autoscale
	setDisabled(_disabled)
	
	if autoscale and !disabled:
		onInitialAutoscale.call_deferred()
		
func setDisabled(_disabled: bool) -> void: pass
	
		
func onInitialAutoscale() -> void:
	if get_viewport() == null: return
	get_viewport().update_mouse_cursor_state()
	onScaleIconUISize(is_mouse_in_ui, true)

func isMouseInUI() -> bool:
	return is_mouse_in_ui

func onItemGainedVisual() -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation", ITEM_GAINED_SPIN_TOTAL_ROTATION, ITEM_GAINED_SPIN_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", -ITEM_GAINED_SPIN_TOTAL_ROTATION * 2, ITEM_GAINED_SPIN_TIME * 2)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", ITEM_GAINED_SPIN_TOTAL_ROTATION, ITEM_GAINED_SPIN_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
	var stween := create_tween()
	stween.tween_property(self, "scale", Vector2(ITEM_GAINED_SCALE_OFFSET, ITEM_GAINED_SCALE_OFFSET), ITEM_GAINED_INITAL_SCALE_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	stween.tween_property(self, "scale", Vector2(-ITEM_GAINED_SCALE_OFFSET, -ITEM_GAINED_SCALE_OFFSET), ITEM_GAINED_RECOVERY_SCALE_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)

func onUpdateCursorVisual(state: bool) -> void: pass
func setDefaultAlpha(_default_alpha: float) -> void:
	default_alpha = _default_alpha
	onUpdateModulate()
