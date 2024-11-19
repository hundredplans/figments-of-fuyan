extends TextureRect

var Boon: BoonGD

@onready var ChargesLabel: Label = %ChargesLabel
@onready var BoonShine: TextureRect = %BoonShine

func setInfo(_Boon: BoonGD) -> void:
	Boon = _Boon
	texture = Boon.getIcon()
	
	onUpdateCharges(Boon.getCharges())
	onUpdateDisabled(Boon.getDisabled())
	onUpdateAscension(Boon.ascended)
	
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	Game.onMouseInUITooltip(state, Boon, self, Vector2(10, -40))
		
func onUpdateCharges(charges: int) -> void:
	if charges == -1: ChargesLabel.text = ""
	else:
		ChargesLabel.text = str(charges)
	
func onUpdateDisabled(disabled: bool) -> void:
	modulate = Color(0.5, 0.5, 0.5) if disabled else Color(1, 1, 1)
		
func onUpdateAscension(ascended: bool) -> void:
	BoonShine.visible = ascended
