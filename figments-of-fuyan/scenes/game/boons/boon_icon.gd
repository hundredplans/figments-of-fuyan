extends TextureRect

signal pressed
var Boon: BoonGD
var disabled: bool
var hoverable: bool

@onready var ChargesLabel: Label = %ChargesLabel
@onready var BoonShine: TextureRect = %BoonShine

func setInfo(_Boon: BoonGD, _hoverable: bool = false) -> void:
	Boon = _Boon
	texture = Boon.getIcon()
	hoverable = _hoverable
	
	onUpdateCharges(Boon.getCharges())
	onUpdateAscension(Boon.ascended)
	
func onDisplayCharges(state: bool) -> void:
	ChargesLabel.visible = state
	
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	Game.onMouseInUITooltip(state, Boon, self, Vector2(10, -40))
	
	if !disabled and hoverable:
		modulate = Color(0.5, 0.5, 0.5) if state else Color(1, 1, 1)
		
func onUpdateCharges(charges: int) -> void:
	if charges == -1: ChargesLabel.text = ""
	else:
		ChargesLabel.text = str(charges)
	
func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	modulate = Color(0.2, 0.2, 0.2) if disabled else Color(1, 1, 1)
		
func onUpdateAscension(ascended: bool) -> void:
	BoonShine.visible = ascended
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and mouse_in_ui and !disabled:
		pressed.emit(Boon)
