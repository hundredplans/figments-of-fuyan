@tool
extends Control
signal pressed
@export var flipped: bool = false
@export var label_text: String
var can_press: bool = false

@onready var click_sfx: AudioStreamWAV = preload("res://assets/sounds/UI/menu_buttons/click.wav")
func _ready():
	pressed.connect(func(): AudioMaster.play_sfx(click_sfx))
	match label_text:
		"": $Label.text = "Insert Text"
		_: $Label.text = label_text
		
	if flipped:
		$Sprite2D.texture = load("res://assets/UI/menu_button/sword_flipped.png")
		var offset: int = Array($Area2D/CollisionPolygon2D.polygon).reduce((func(a: int, xy: Vector2): if a > xy.x: return a else: return xy.x), 0)
		$Area2D/CollisionPolygon2D.polygon = Array($Area2D/CollisionPolygon2D.polygon).map(func(xy: Vector2): return Vector2((xy.x * -1) + offset, xy.y))
		$Label.position.x += 200
		$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		
func _process(_delta: float) -> void:
	if can_press and Input.is_action_just_pressed("LeftClick"): pressed.emit()

func _on_area_2d_mouse_entered(): can_press = true

func _on_area_2d_mouse_exited(): can_press = false

