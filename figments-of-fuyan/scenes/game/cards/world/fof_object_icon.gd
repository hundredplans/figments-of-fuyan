extends Node3D

var FofObject: FofGD
@onready var Icon: Sprite3D = $Icon
@onready var ChargesLabel: Label3D = %ChargesLabel

func _ready() -> void:
	setDepthTest(depth_test)

func setInfo(_FofObject: FofGD) -> void:
	FofObject = _FofObject
	if FofObject is FieldEffectGD or FofObject is TraitGD:
		ChargesLabel.position.x = FofObject.info.charges_label_position.x
		ChargesLabel.position.y = FofObject.info.charges_label_position.y
		FofObject.update_charges.connect(setCharges)
		setCharges(FofObject.getCharges())

func setTexture(tx: Texture2D) -> void:
	Icon.texture = tx
	
func setModulate(color: Color) -> void:
	Icon.modulate = color
	
var depth_test: bool
func setDepthTest(state: bool) -> void:
	depth_test = state
	
	if Icon != null:
		Icon.no_depth_test = state
		ChargesLabel.no_depth_test = state
		
func setCharges(charges: int) -> void:
	ChargesLabel.visible = charges >= 0
	ChargesLabel.text = str(charges)
