extends TextureRect

signal pressed
var Boon: BoonGD
var disabled: bool
var hoverable: bool

const SPIN_SPEED: float = 10

@onready var ChargesLabel: Label = %ChargesLabel
@onready var AscendedShine: TextureRect = %BoonShine

func _ready() -> void:
	AscendedShine.pivot_offset = AscendedShine.size / 2

func setInfo(_Boon: BoonGD, _hoverable: bool = false) -> void:
	Boon = _Boon
	Boon.update_ascend.connect(onUpdateAscension)
	texture = Boon.getIcon()
	hoverable = _hoverable
	
	onUpdateCharges(Boon.getCharges())
	onUpdateAscension(Boon.ascended)
	
func onDisplayCharges(state: bool) -> void:
	ChargesLabel.visible = state
	
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	Game.onMouseInUITooltip(state, Boon, self, true)
	
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
	AscendedShine.visible = ascended
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and mouse_in_ui and !disabled:
		pressed.emit(Boon)

	if AscendedShine.visible:
		AscendedShine.rotation_degrees += delta * SPIN_SPEED
