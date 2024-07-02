extends Control
@onready var label: Label = %Label
@onready var description: RichTextLabel = %Description
@onready var AbilityCharges: Label = %AbilityCharges
@onready var button: TextureButton = %Button
var ability: AbilityGD
signal pressed
signal mouse_in_ui

func _ready() -> void:
	button.pressed.connect(func(): pressed.emit())
	button.mouse_in_ui.connect(func(x: bool): mouse_in_ui.emit(x))

func setDisabled(x: bool) -> void:
	button.setDisabled(x)

#const SCALE_TWEEN_TIME: float = 0.1
#func _on_mouse_entered():
	#var ScaleTween := create_tween()
	#ScaleTween.tween_property(self, "scale", Vector2(1.1, 1.1), SCALE_TWEEN_TIME)
#
#func _on_mouse_exited():
	#var ScaleTween := create_tween()
	#ScaleTween.tween_property(self, "scale", Vector2.ONE, SCALE_TWEEN_TIME)

