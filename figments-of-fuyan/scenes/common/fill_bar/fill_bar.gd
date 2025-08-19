extends Control

@export var bg_color: Color
@export var fg_color: Color
@export var max_value: int

@onready var BackgroundBar: ColorRect = %BackgroundBar
@onready var ForegroundBar: ColorRect = %ForegroundBar

var value: int
func _ready() -> void:
	onUpdateColors(bg_color, fg_color)
	onUpdate()
	
func onUpdateColors(_bg_color: Color, _fg_color: Color) -> void:
	BackgroundBar.color = _bg_color
	ForegroundBar.color = _fg_color
	
func setMaxValue(_max_value: int) -> void:
	max_value = _max_value
	onUpdate()
	
func setValue(_value: int) -> void:
	value = clamp(_value, 0, max_value)
	onUpdate()
	
func onUpdate() -> void:
	var p: float = float(value) / float(max_value)
	ForegroundBar.size.x = (BackgroundBar.size.x * p) if max_value > 0 else 0.0
