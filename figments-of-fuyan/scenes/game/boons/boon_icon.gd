extends TextureRect

var Boon: BoonGD

@onready var ChargesLabel: Label = %ChargesLabel
@onready var BoonShine: TextureRect = %BoonShine

@export var TooltipPacked: PackedScene
const TOOLTIP_DELAY: float = 0.3
const OFFSET := Vector2(10, -40)

func setInfo(_Boon: BoonGD) -> void:
	Boon = _Boon
	texture = Boon.getIcon()
	
	onUpdateCharges(Boon.getCharges())
	onUpdateDisabled(Boon.getDisabled())
	onUpdateAscension(Boon.ascended)
	
var Tooltip: Control
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	if state and Tooltip == null:
		await get_tree().create_timer(TOOLTIP_DELAY).timeout
		if state:
			Tooltip = TooltipPacked.instantiate()
			add_child(Tooltip)
			Tooltip.setInfo(Boon)
			Tooltip.global_position = get_viewport().get_mouse_position() + OFFSET
		
	elif !state and Tooltip != null:
		Tooltip.queue_free()
		
func onUpdateCharges(charges: int) -> void:
	if charges == -1: ChargesLabel.text = ""
	else:
		ChargesLabel.text = str(charges)
	
func onUpdateDisabled(disabled: bool) -> void:
	modulate = Color(0.5, 0.5, 0.5) if disabled else Color(1, 1, 1)
		
func onUpdateAscension(ascended: bool) -> void:
	BoonShine.visible = ascended
