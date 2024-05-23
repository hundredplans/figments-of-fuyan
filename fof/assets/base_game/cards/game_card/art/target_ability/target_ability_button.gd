extends TextureButton

const COLORS: Dictionary = {
	"BASE": Color(1, 1, 1),
	"GREY": Color(0.3, 0.3, 0.3),
	"GREEN": Color(0, 1, 0),
	"YELLOW": Color(1, 1, 0),
	"RED": Color(1, 0, 0)
}

var ability: AbilityGD
@onready var label := $Label

func _ready() -> void:
	Helper.create_button_clickmask(self)

func onUpdateAbility(Unit: UnitGD, disable: bool) -> void:
	var charges: int = ability.charges
	var max_charges: int = ability.max_charges
	
	var text: String = str(charges) if charges >= 0 else "∞"
	label.text = str(text)
	var color: String = "BASE"
	if charges == 0 or disable: color = "GREY"; disable = true
	elif charges > max_charges: color = "GREEN"
	elif charges < max_charges: color = "YELLOW"
	
	label.modulate = COLORS[color]
	if Unit.team == 0: disabled = disable
	else: disabled = true
		

const GROW_SPEED: float = 0.1
func _on_pressed():
	var GrowTween := create_tween()
	GrowTween.tween_property(self, "scale", Vector2(1.1, 1.1), GROW_SPEED)
	GrowTween.tween_property(self, "scale", Vector2.ONE, GROW_SPEED * 2)

const ROTATE_OFFSET: int = 10
const ROTATE_SPEED: float = 0.16
var is_rotating: bool = false
func _on_mouse_entered():
	if !is_rotating:
		var RotateTween := create_tween()
		RotateTween.tween_property(self, "rotation_degrees", ROTATE_OFFSET, ROTATE_SPEED)
		RotateTween.tween_property(self, "rotation_degrees", -ROTATE_OFFSET, ROTATE_SPEED)
		RotateTween.tween_property(self, "rotation_degrees", 0, ROTATE_SPEED)
		RotateTween.finished.connect(onRotateTweenFinished)
		is_rotating = true
		
func onRotateTweenFinished() -> void:
	is_rotating = false
