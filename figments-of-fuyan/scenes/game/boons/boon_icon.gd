extends TbcUI

var Boon: BoonGD

const SPIN_SPEED: float = 10

@onready var BoonTextureRect: TextureRect = %BoonTextureRect
@onready var ChargesLabel: Label = %ChargesLabel

func setInfo(_Boon: BoonGD, _hoverable: bool = false, _draggable: bool = false) -> void:
	Boon = _Boon
	BoonTextureRect.texture = Boon.getIcon()
	hoverable = _hoverable
	draggable = _draggable
	
	onUpdateCharges(Boon.getCharges())
	
func onDisplayCharges(state: bool) -> void:
	ChargesLabel.visible = state
	
func onMouseInUI(state: bool) -> void:
	super(state)
	#if !disable_tooltip:
		#Game.onMouseInUITooltip(state, Boon, self, true)
		
func onUpdateCharges(charges: int) -> void:
	if !Boon.info.use_charges: return
	ChargesLabel.text = str(charges)
	
func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	onUpdateModulate()
		
func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	super(_mouse_filter)
	mouse_filter = _mouse_filter

func getPriceLabelPosition() -> Vector2:
	return Vector2(0, 83)

func getItem() -> FofGD: return Boon
