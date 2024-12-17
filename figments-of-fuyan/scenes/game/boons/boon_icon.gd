extends TextureRect

signal pressed
var Boon: BoonGD
var disabled: bool
var hoverable: bool

const SPIN_SPEED: float = 10

@onready var ChargesLabel: Label = %ChargesLabel
@export var ASCENDED_CANVAS_MATERIAL: ShaderMaterial
@export var ASCENDED_CANVAS_MATERIAL_DISABLED: ShaderMaterial

var ascended: bool
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
	#onDisplayCharges(charges == -1)
	if charges == -1: ChargesLabel.text = ""
	else:
		ChargesLabel.text = str(charges)
	
func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	modulate = Color(0.2, 0.2, 0.2) if disabled else Color(1, 1, 1)
	onUpdateAscension(ascended)
		
func onUpdateAscension(_ascended: bool) -> void:
	ascended = _ascended
	material = (ASCENDED_CANVAS_MATERIAL if !disabled else ASCENDED_CANVAS_MATERIAL_DISABLED) if ascended else null
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and mouse_in_ui and !disabled:
		pressed.emit(Boon)
