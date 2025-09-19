class_name DefaultControl extends Control

signal mouse_in_ui
@export var SCALE_SPEED: float = 0.25
@export var SCALE_MAX: float = 1.1

@export var auto_pivot_offset: bool = true
@export var autoscale: bool
@export var BASE_COLOR := Color("ffffff")
@export var HOVER_COLOR := Color("aaaaaa")
@export var DISABLED_COLOR := Color("#888888")

var disabled: bool
var is_mouse_in_ui: bool
func _ready() -> void:
	onUpdateModulate()
	if auto_pivot_offset:
		pivot_offset = (size / 2.0)

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	is_mouse_in_ui = state
		
	onUpdateModulate()
	if !autoscale or disabled: return
	onScaleSize(is_mouse_in_ui)

func onUpdateModulate() -> void:
	modulate = (BASE_COLOR if !is_mouse_in_ui else HOVER_COLOR) if !disabled else DISABLED_COLOR
	
func setDisabled(state: bool) -> void:
	disabled = state
	onUpdateModulate()

var ScaleTween: Tween
func onScaleSize(state: bool, instant: bool = false) -> void:
	var target_value: float = (SCALE_MAX if state else 1.0) - scale.x
	if !instant:
		if ScaleTween: ScaleTween.kill()
		ScaleTween = create_tween()
		ScaleTween.tween_property(self, "scale", Vector2(target_value, target_value), SCALE_SPEED)\
				.as_relative().set_trans(Tween.TRANS_SINE)
	else: scale += Vector2(target_value, target_value)

func onChangeHoverColor(color: Color) -> void:
	HOVER_COLOR = color
	onUpdateModulate()
	
func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	mouse_filter = _mouse_filter
