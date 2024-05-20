class_name InfoFXGD
extends Resource

@export var texture: Texture2D
@export_multiline var tooltip: String
@export var fx_type: String
@export var can_hover: bool = false
var charges: int
var Unit: UnitGD

func _init(_Unit: UnitGD = null, _charge: int = -1) -> void:
	Unit = _Unit
	charges = _charge
