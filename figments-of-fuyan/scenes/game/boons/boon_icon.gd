extends TbcUI

var Boon: BoonGD

const SPIN_SPEED: float = 10

@onready var NameLabel: Label = %NameLabel
@onready var TierLabel: Label = %TierLabel

@onready var BoonTextureRect: TextureRect = %BoonTextureRect
@onready var ChargesLabel: Label = %ChargesLabel

func setInfo(_Boon: BoonGD, _hoverable: bool = false, _draggable: bool = false, _autoscale: bool = false) -> void:
	Boon = _Boon
	Boon.update_tier.connect(onUpdateTier)
	Boon.update_disabled.connect(setDisabled)
	BoonTextureRect.texture = Boon.getIcon()
	hoverable = _hoverable
	draggable = _draggable
	autoscale = _autoscale
	
	onUpdateCharges(Boon.getCharges())
	setMouseFilter(mouse_filter)
	onUpdateTier(Boon.getTier())
	
func onDisplayCharges(state: bool) -> void:
	ChargesLabel.visible = state
	
func setSizeScale(n: int) -> void:
	var nsize: int = 80 * n
	custom_minimum_size = Vector2(nsize, nsize)
	BoonTextureRect.custom_minimum_size = Vector2(nsize, nsize)
	size = Vector2(nsize, nsize)
	pivot_offset = (size / 2)
	
func onMouseInUI(state: bool) -> void:
	super(state)
	if !disable_tooltip:
		Game.onMouseInUITooltip(state, Boon, self, true)
		
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
	return Vector2(0, 113)

func getItem() -> FofGD: return Boon

func onUpdateTier(_tier: int) -> void:
	if TierLabel.text != "":
		TierLabel.modulate = Game.getTierColor(Boon.getTier())
		TierLabel.text = "Tier " + Game.getTierString(Boon.getTier())
	
func onShowTierLabel(label_offset: int = 0) -> void:
	TierLabel.modulate = Game.getTierColor(Boon.getTier())
	TierLabel.text = "Tier " + Game.getTierString(Boon.getTier())
	TierLabel.label_settings = getToolBoonLabelSettings(label_offset)
	
func onShowNameLabel(label_offset: int = 0) -> void:
	NameLabel.modulate = Game.getRarityColor(Boon.getRarity())
	NameLabel.text = Boon.info.name
	NameLabel.label_settings = getToolBoonLabelSettings(label_offset)
