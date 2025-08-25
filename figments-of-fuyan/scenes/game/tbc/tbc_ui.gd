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

var can_disable_dragging_pressed: bool
var end_drag_on_release: bool = true
var current_mouse_filter: Control.MouseFilter

var is_mouse_in_ui: bool
var disabled: bool
var disable_tooltip: bool

var autoscale: bool
var draggable: bool
var is_dragging: bool
var hoverable: bool

var original_tooltip_state: bool
var original_icon_position: Vector2
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
	elif Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !disabled:
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
	if is_dragging: return
	mouse_in_ui.emit(state)
	onUpdateModulate()
	
	if !autoscale: return
	onScaleIconUISize(is_mouse_in_ui, false)

func onUpdateModulate() -> void:
	var color: Color
	if disabled: color = Color(0.2, 0.2, 0.2)
	elif (is_mouse_in_ui and hoverable) or is_dragging: color = Color(0.5, 0.5, 0.5)
	else: color = Color.WHITE
	ModulateMain.modulate = color

func setDisableTooltip(_disable_tooltip: bool) -> void:
	disable_tooltip = _disable_tooltip

func setDraggable(_draggable: bool) -> void:
	draggable = _draggable

func setHoverable(state: bool) -> void:
	hoverable = state
	get_viewport().update_mouse_cursor_state()
	onUpdateModulate()
	
func onDragBegin() -> void:
	original_tooltip_state = disable_tooltip
	original_icon_position = position
	original_mouse_filter = current_mouse_filter
	disable_tooltip = true
	
	setMouseFilter(Control.MouseFilter.MOUSE_FILTER_IGNORE)
	Game.onMouseInUITooltip(false)
	drag_begin.emit(self)
	
	get_viewport().call_deferred("update_mouse_cursor_state")
	onUpdateModulate()
	
	await get_tree().process_frame
	var original_global_position: Vector2 = global_position
	top_level = true
	global_position = original_global_position
	is_dragging = true
	
	await get_tree().create_timer(TIME_TO_ENABLE_DRAGGING).timeout
	can_disable_dragging_pressed = true
	
func onDragEnd() -> void:
	is_dragging = false
	disable_tooltip = original_tooltip_state
	drag_end.emit(self)
	setMouseFilter(original_mouse_filter)
	
	onDragPositionReset()
	
	get_viewport().call_deferred("update_mouse_cursor_state")
	onUpdateModulate()
	
var ignore_drag_position_reset: bool
func setIgnoreDragPositionReset(_ignore_drag_position_reset: bool) -> void:
	ignore_drag_position_reset = _ignore_drag_position_reset
	
func onDragPositionReset() -> void:
	if ignore_drag_position_reset: return
	top_level = false
	position = original_icon_position
	rotation_degrees = 0
	
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
