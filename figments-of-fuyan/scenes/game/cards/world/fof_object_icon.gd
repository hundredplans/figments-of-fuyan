extends Node3D

var FofObject: FofGD
@onready var Icon: Sprite3D = $Icon

func _ready() -> void:
	setDepthTest(depth_test)

func setInfo(_FofObject: FofGD) -> void:
	FofObject = _FofObject

func setTexture(tx: Texture2D) -> void:
	Icon.texture = tx
	
func setModulate(color: Color) -> void:
	Icon.modulate = color
	
var depth_test: bool
func setDepthTest(state: bool) -> void:
	depth_test = state
	
	if Icon != null:
		Icon.no_depth_test = state
