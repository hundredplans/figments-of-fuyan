extends Control
signal pressed
var can_press: bool = false
@export var label_text: String

func _process(_delta: float) -> void:
	if can_press and Input.is_action_just_pressed("LeftClick"):
		pressed.emit()

func _ready():
	$Label.text = label_text

func _on_mouse_entered(): can_press = true
func _on_mouse_exited(): can_press = false
