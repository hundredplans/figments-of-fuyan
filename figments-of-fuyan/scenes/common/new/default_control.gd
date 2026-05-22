class_name DefaultControl extends Control

signal mouse_in_ui
@export var SCALE_SPEED: float = 0.25
@export var SCALE_MAX: float = 1.1

@export var auto_pivot_offset: bool = true
@export var autoscale: bool
@export var BASE_COLOR := Color("ffffff")
@export var HOVER_COLOR := Color("aaaaaa")
@export var DISABLED_COLOR := Color("#888888")
@export var use_self_modulate: bool

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
	var color: Color = (BASE_COLOR if !is_mouse_in_ui else HOVER_COLOR) if !disabled else DISABLED_COLOR 
	if !use_self_modulate: modulate = color
	else: self_modulate = color
	
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

var FadeTween: Tween
func onFade(fade_in: bool) -> void:
	var value: float = 1.0 if fade_in else 0.0
	if FadeTween: FadeTween.kill()
	FadeTween = create_tween()
	FadeTween.tween_property(self, "modulate:a", value, Game.FADE_TIME)
	
	if !fade_in:
		setMouseFilter(Control.MouseFilter.MOUSE_FILTER_IGNORE)
		var OldFadeTween: Tween = FadeTween
		await FadeTween.finished
		if FadeTween == OldFadeTween: return
		visible = false
	else:
		visible = true
		await FadeTween.finished
		setMouseFilter(Control.MouseFilter.MOUSE_FILTER_STOP)
