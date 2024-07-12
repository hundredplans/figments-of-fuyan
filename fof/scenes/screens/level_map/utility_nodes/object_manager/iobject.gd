class_name IObjectGD
extends Resource

var Units: UnitsGD
var ActionManager: ActionManagerGD

var BaseTile: TileGD
var interactable_tiles: Array
var info: ObjectInteractTilesGD
var charges: int

func setInfo(_BaseTile: TileGD = null, _interactable_tiles: Array = [], _info: ObjectInteractTilesGD = null) -> void:
	BaseTile = _BaseTile
	interactable_tiles = _interactable_tiles
	info = _info
	charges = info.max_charges
	if has_method("onReady"): call("onReady")

func _init() -> void:
	Helper.onCreateChildReferences(self)
