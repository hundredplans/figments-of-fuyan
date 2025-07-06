extends TextureRect

signal pressed
signal mouse_in_ui

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
	
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	Game.onMouseInUITooltip(state, Boon, self, true)
	
	onUpdateModulate()
	mouse_in_ui.emit(state)
		
func onUpdateCharges(charges: int) -> void:
	if !Boon.info.use_charges: return
	ChargesLabel.text = str(charges)
	
func setHighlightOnHover(state: bool) -> void:
	hoverable = state
	onUpdateModulate()
	
func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	onUpdateModulate()
	onUpdateAscension(ascended)
		
func onUpdateModulate() -> void:
	modulate = Color(0.2, 0.2, 0.2) if disabled else\
		(Color(0.5, 0.5, 0.5) if is_mouse_in_ui and hoverable else Color.WHITE)
		
func onUpdateAscension(_ascended: bool) -> void:
	ascended = _ascended
	material = (ASCENDED_CANVAS_MATERIAL if !disabled else ASCENDED_CANVAS_MATERIAL_DISABLED) if ascended else null

func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	mouse_filter = _mouse_filter
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !disabled:
		pressed.emit(Boon)
