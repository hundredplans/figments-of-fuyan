class_name DObjectGD
extends Resource

var BaseTile: TileGD
var info: DObjectInfoGD

func _init() -> void:
	Helper.onCreateChildReferences(self)
	
func setInfo(_BaseTile: TileGD, _info: DObjectInfoGD) -> void:
	BaseTile = _BaseTile
	info = _info
