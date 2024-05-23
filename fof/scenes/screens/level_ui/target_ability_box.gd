extends TextureButton
@onready var label: Label = %Label
@onready var description: RichTextLabel = %Description
@onready var AbilityCharges: Label = %AbilityCharges
var ability: AbilityGD

const SCALE_TWEEN_TIME: float = 0.1
func _on_mouse_entered():
	var ScaleTween := create_tween()
	ScaleTween.tween_property(self, "scale", Vector2(1.1, 1.1), SCALE_TWEEN_TIME)

func _on_mouse_exited():
	var ScaleTween := create_tween()
	ScaleTween.tween_property(self, "scale", Vector2.ONE, SCALE_TWEEN_TIME)

